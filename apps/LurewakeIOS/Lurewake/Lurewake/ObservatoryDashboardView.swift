import SwiftUI

private struct ObservatoryHealth: Decodable {
    let status: String
    let service: String
    let version: String
}

struct ObservatoryDashboardView: View {
    @State private var health: ObservatoryHealth?
    @State private var isChecking = false
    @State private var connectionMessage = "Not checked"

    private var isConnected: Bool {
        health?.status == "ok"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                header

                connectionCard

                HStack(spacing: 12) {
                    metricCard(
                        title: "ACTIVE LURES",
                        value: "—",
                        caption: "Not configured",
                        icon: "scope"
                    )

                    metricCard(
                        title: "OBSERVED EVENTS",
                        value: "—",
                        caption: "Not configured",
                        icon: "waveform.path"
                    )
                }

                foundationCard
            }
            .padding(.horizontal, 22)
            .padding(.top, 30)
            .padding(.bottom, 110)
        }
        .background(LurewakeTheme.ink)
        .task {
            await checkConnection()
        }
        .refreshable {
            await checkConnection()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(
                    "FIELD OBSERVATORY",
                    systemImage: "circle.hexagongrid"
                )

                Spacer()

                Text("V0.1 / LIFECYCLE")
            }
            .font(.system(
                size: 10,
                weight: .semibold,
                design: .monospaced
            ))
            .foregroundStyle(LurewakeTheme.gold)

            Text("The Observatory")
                .font(.system(
                    size: 32,
                    weight: .semibold,
                    design: .rounded
                ))
                .foregroundStyle(LurewakeTheme.parchment)

            Text("Every signal leaves a wake.")
                .font(.system(size: 15))
                .foregroundStyle(
                    LurewakeTheme.parchment.opacity(0.65)
                )
        }
    }

    private var connectionCard: some View {
        VStack(alignment: .leading, spacing: 18) {

            HStack {
                Image(systemName: "server.rack")
                    .foregroundStyle(LurewakeTheme.gold)

                Text("BACKEND CONNECTION")
                    .font(.system(
                        size: 11,
                        weight: .bold,
                        design: .monospaced
                    ))
                    .foregroundStyle(LurewakeTheme.gold)

                Spacer()

                Circle()
                    .fill(
                        isConnected
                        ? Color.green
                        : LurewakeTheme.gold
                    )
                    .frame(width: 9, height: 9)
            }

            Text(
                isChecking
                ? "Checking connection..."
                : (isConnected ? "API online" : "API unavailable")
            )
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(LurewakeTheme.parchment)

            Text(
                isConnected
                ? "The local Vapor service responded successfully."
                : "Start the local Vapor service to connect the observatory."
            )
            .font(.system(size: 13))
            .foregroundStyle(
                LurewakeTheme.parchment.opacity(0.65)
            )

            Text(connectionMessage)
                .font(.system(
                    size: 11,
                    design: .monospaced
                ))
                .foregroundStyle(LurewakeTheme.gold)

            Button {
                Task {
                    await checkConnection()
                }
            } label: {
                Label(
                    "Check connection",
                    systemImage: "arrow.clockwise"
                )
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .tint(LurewakeTheme.gold)
            .disabled(isChecking)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LurewakeTheme.indigo,
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private func metricCard(
        title: String,
        value: String,
        caption: String,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            Image(systemName: icon)
                .foregroundStyle(LurewakeTheme.gold)

            Text(title)
                .font(.system(
                    size: 9,
                    weight: .bold,
                    design: .monospaced
                ))
                .foregroundStyle(
                    LurewakeTheme.parchment.opacity(0.6)
                )

            Text(value)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(LurewakeTheme.parchment)

            Text(caption)
                .font(.system(size: 11))
                .foregroundStyle(
                    LurewakeTheme.parchment.opacity(0.55)
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(18)
        .background(
            LurewakeTheme.indigo,
            in: RoundedRectangle(cornerRadius: 19)
        )
    }

    private var foundationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SIGNAL PIPELINE")
                .font(.system(
                    size: 11,
                    weight: .bold,
                    design: .monospaced
                ))
                .foregroundStyle(LurewakeTheme.gold)

            Text("Awaiting first deployment")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(LurewakeTheme.parchment)

            Text(
                "Lure issuance, interaction collection, and detection proof are not configured yet."
            )
            .font(.system(size: 13))
            .foregroundStyle(
                LurewakeTheme.parchment.opacity(0.65)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            LurewakeTheme.indigo,
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    @MainActor
    private func checkConnection() async {
        isChecking = true
        defer { isChecking = false }

        guard let url = URL(
            string: "http://127.0.0.1:8080/health"
        ) else {
            connectionMessage = "Invalid API address"
            health = nil
            return
        }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 5

            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                health = nil
                connectionMessage = "Unexpected HTTP response"
                return
            }

            let result = try JSONDecoder().decode(
                ObservatoryHealth.self,
                from: data
            )

            guard result.status == "ok",
                  result.service == "lurewake-api" else {
                health = nil
                connectionMessage = "Unexpected service response"
                return
            }

            health = result
            connectionMessage = "Version: \(result.version)"

        } catch {
            health = nil
            connectionMessage = "Connection failed: \(error.localizedDescription)"
        }
    }
}
