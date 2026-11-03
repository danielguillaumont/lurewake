import Foundation
import SwiftUI

// MARK: - API Response Models

private struct InventoryLure: Decodable, Identifiable {
    let id: UUID
    let name: String
    let kind: String
    let status: String
}

private struct InventoryPayload: Decodable {
    let items: [InventoryLure]
    let returnedCount: Int
    let limit: Int
}

private enum InventoryPhase {
    case idle
    case loading
    case loaded(InventoryPayload)
    case failed(String)
}

// MARK: - Native Lures Inventory

struct LuresInventoryView: View {

    @State private var phase: InventoryPhase = .idle

    var body: some View {
        ZStack {
            LurewakeTheme.ink
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    LurewakeTheme.indigo,
                    LurewakeTheme.ink
                ],
                center: .top,
                startRadius: 20,
                endRadius: 550
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    VStack(alignment: .leading, spacing: 12) {
                        Text("lures")
                            .font(LurewakeTheme.pageTitleFont)
                            .tracking(-2)
                            .foregroundStyle(LurewakeTheme.parchment)

                        Text(
                            "The quiet markers that reveal when " +
                            "something moves where it shouldn't."
                        )
                        .font(LurewakeTheme.bodyFont)
                        .foregroundStyle(LurewakeTheme.mutedText)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                    }

                    connectionPanel

                    LurewakeEyebrow(title: "Registered lures")

                    inventoryContent

                    Text("READ-ONLY  /  LOCAL DEVELOPMENT")
                        .font(LurewakeTheme.eyebrowFont)
                        .tracking(1)
                        .foregroundStyle(
                            LurewakeTheme.parchment.opacity(0.4)
                        )
                        .frame(maxWidth: .infinity)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.horizontal, LurewakeTheme.screenPadding)
                .padding(.top, 22)
                .padding(.bottom, 96)
            }
            .refreshable {
                await loadInventory()
            }
        }
        .task {
            if case .idle = phase {
                await loadInventory()
            }
        }
    }

    private var header: some View {
        HStack {
            LurewakeEyebrow(title: "Lurewake / Inventory")

            Spacer()

            Text("V0.0")
                .font(LurewakeTheme.eyebrowFont)
                .foregroundStyle(LurewakeTheme.mutedText)
        }
    }

    private var connectionPanel: some View {
        LurewakePanel {
            HStack(spacing: 14) {
                Image(systemName: connectionSymbol)
                    .font(.system(size: 23, weight: .light))
                    .foregroundStyle(LurewakeTheme.gold)

                VStack(alignment: .leading, spacing: 5) {
                    Text(connectionTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(LurewakeTheme.parchment)

                    Text("VAPOR / POSTGRESQL / LOCAL")
                        .font(LurewakeTheme.eyebrowFont)
                        .foregroundStyle(LurewakeTheme.mutedText)
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var connectionSymbol: String {
        switch phase {
        case .idle, .loading:
            return "arrow.triangle.2.circlepath"
        case .loaded:
            return "checkmark.circle"
        case .failed:
            return "exclamationmark.triangle"
        }
    }

    private var connectionTitle: String {
        switch phase {
        case .idle, .loading:
            return "Checking inventory connection"
        case .loaded:
            return "Inventory synchronized"
        case .failed:
            return "Inventory connection unavailable"
        }
    }

    @ViewBuilder
    private var inventoryContent: some View {
        switch phase {
        case .idle, .loading:
            LurewakePanel {
                HStack(spacing: 14) {
                    ProgressView()
                        .tint(LurewakeTheme.gold)

                    Text("Reading the live inventory...")
                        .foregroundStyle(LurewakeTheme.parchment)
                }
            }

        case .failed(let message):
            LurewakePanel {
                VStack(alignment: .leading, spacing: 18) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 35, weight: .light))
                        .foregroundStyle(LurewakeTheme.gold)

                    Text("Connection lost")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(LurewakeTheme.parchment)

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(LurewakeTheme.mutedText)

                    refreshButton(title: "Retry connection")
                }
            }

        case .loaded(let payload):
            if payload.items.isEmpty {
                emptyInventory
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    Text(
                        "Showing \(payload.returnedCount) " +
                        "of up to \(payload.limit) records"
                    )
                    .font(.subheadline)
                    .foregroundStyle(LurewakeTheme.mutedText)

                    ForEach(payload.items) { lure in
                        LurewakePanel {
                            VStack(
                                alignment: .leading,
                                spacing: 12
                            ) {
                                HStack {
                                    Text(lure.name)
                                        .font(.headline)
                                        .foregroundStyle(
                                            LurewakeTheme.parchment
                                        )

                                    Spacer()

                                    Image(systemName: "scope")
                                        .foregroundStyle(
                                            LurewakeTheme.gold
                                        )
                                }

                                Text(lure.kind.uppercased())
                                    .font(LurewakeTheme.eyebrowFont)
                                    .foregroundStyle(
                                        LurewakeTheme.mutedText
                                    )

                                Text("STATUS / " + lure.status.uppercased())
                                    .font(LurewakeTheme.eyebrowFont)
                                    .foregroundStyle(LurewakeTheme.gold)
                            }
                        }
                    }

                    refreshButton(title: "Refresh inventory")
                }
            }
        }
    }

    private var emptyInventory: some View {
        LurewakePanel {
            VStack(spacing: 13) {
                ZStack {
                    Circle()
                        .stroke(
                            LurewakeTheme.gold.opacity(0.12),
                            lineWidth: 1
                        )
                        .frame(width: 116, height: 116)

                    Circle()
                        .stroke(
                            LurewakeTheme.gold.opacity(0.3),
                            lineWidth: 1
                        )
                        .frame(width: 84, height: 84)

                    Circle()
                        .fill(LurewakeTheme.gold.opacity(0.08))
                        .frame(width: 60, height: 60)

                    Image(systemName: "scope")
                        .font(.system(size: 29, weight: .ultraLight))
                        .foregroundStyle(LurewakeTheme.gold)
                }
                .padding(.top, 2)

                Text("No lures registered")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(LurewakeTheme.parchment)

                Text(
                    "PostgreSQL is responding, but the inventory " +
                    "contains no records yet. No digital lures " +
                    "have been issued or deployed."
                )
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(LurewakeTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)

                Text("00 / REGISTERED")
                    .font(LurewakeTheme.eyebrowFont)
                    .tracking(1.5)
                    .foregroundStyle(LurewakeTheme.gold)

                refreshButton(title: "Check inventory again")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        }
    }

    private func refreshButton(title: String) -> some View {
        Button {
            Task {
                await loadInventory()
            }
        } label: {
            Label(title, systemImage: "arrow.clockwise")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(LurewakeTheme.ink)
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background(
                    LurewakeTheme.gold,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Live API Request

    @MainActor
    private func loadInventory() async {
        if case .loading = phase {
            return
        }

        phase = .loading

        guard let url = URL(
            string: "http://127.0.0.1:8080/api/v1/lures"
        ) else {
            phase = .failed("Invalid local API address.")
            return
        }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 8
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Accept"
            )

            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let http = response as? HTTPURLResponse else {
                phase = .failed("No HTTP response received.")
                return
            }

            guard http.statusCode == 200 else {
                phase = .failed(
                    "The API returned HTTP \(http.statusCode)."
                )
                return
            }

            let payload = try JSONDecoder().decode(
                InventoryPayload.self,
                from: data
            )

            phase = .loaded(payload)

        } catch is DecodingError {
            phase = .failed(
                "The API responded, but its inventory data " +
                "did not match the expected format."
            )
        } catch {
            phase = .failed(
                "Cannot reach the local Lurewake API. " +
                "Check that Vapor is running on port 8080."
            )
        }
    }
}

#Preview {
    LuresInventoryView()
}
