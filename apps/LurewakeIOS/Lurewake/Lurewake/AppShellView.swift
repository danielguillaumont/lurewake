
import SwiftUI

struct AppShellView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label(
                        "Overview",
                        systemImage: "square.grid.2x2.fill"
                    )
                }

            PendingFeatureView(
                title: "Lures",
                symbol: "scope",
                description:
                    "Plant controlled digital tripwires " +
                    "across authorized environments.",
                nextStep:
                    "Lure inventory and issuance workflows"
            )
            .tabItem {
                Label("Lures", systemImage: "scope")
            }

            PendingFeatureView(
                title: "Activity",
                symbol: "waveform.path",
                description:
                    "Follow the wake left behind when " +
                    "an authorized lure is encountered.",
                nextStep:
                    "Real event collection and investigation"
            )
            .tabItem {
                Label("Activity", systemImage: "waveform.path")
            }

            PendingFeatureView(
                title: "Proof",
                symbol: "checkmark.shield",
                description:
                    "Examine evidence showing whether " +
                    "the detection pipeline responded.",
                nextStep:
                    "Evidence-backed detection validation"
            )
            .tabItem {
                Label(
                    "Proof",
                    systemImage: "checkmark.shield"
                )
            }
        }
        .tint(LurewakeTheme.gold)
        .preferredColorScheme(.dark)
    }
}

private struct PendingFeatureView: View {
    let title: String
    let symbol: String
    let description: String
    let nextStep: String

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
                VStack(alignment: .leading, spacing: 0) {
                    header

                    Image(systemName: symbol)
                        .font(
                            .system(
                                size: 50,
                                weight: .ultraLight
                            )
                        )
                        .foregroundStyle(LurewakeTheme.gold)
                        .frame(width: 122, height: 122)
                        .background {
                            Circle()
                                .fill(LurewakeTheme.indigo)
                        }
                        .overlay {
                            Circle()
                                .stroke(
                                    LurewakeTheme.gold.opacity(0.3),
                                    lineWidth: 1
                                )
                        }
                        .padding(.top, 54)

                    Text(title.lowercased())
                        .font(
                            .system(
                                size: 48,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .tracking(-2)
                        .foregroundStyle(
                            LurewakeTheme.parchment
                        )
                        .padding(.top, 35)

                    Text(description)
                        .font(
                            .system(
                                size: 18,
                                weight: .light
                            )
                        )
                        .foregroundStyle(
                            LurewakeTheme.parchment.opacity(0.75)
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .padding(.top, 16)

                    Rectangle()
                        .fill(
                            LurewakeTheme.gold.opacity(0.3)
                        )
                        .frame(height: 1)
                        .padding(.vertical, 32)

                    statusCard
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.horizontal, 26)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
    }

    private var header: some View {
        HStack {
            Circle()
                .fill(LurewakeTheme.gold)
                .frame(width: 7, height: 7)

            Text("LUREWAKE / OBSERVATORY")
                .tracking(1.1)

            Spacer()

            Text("V0.0")
        }
        .font(
            .system(
                size: 10,
                weight: .semibold,
                design: .monospaced
            )
        )
        .foregroundStyle(
            LurewakeTheme.parchment.opacity(0.65)
        )
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 9) {
                Image(systemName: "circle.dotted")
                    .foregroundStyle(LurewakeTheme.gold)

                Text("AWAITING IMPLEMENTATION")
                    .tracking(1)
                    .foregroundStyle(LurewakeTheme.gold)
            }
            .font(
                .system(
                    size: 11,
                    weight: .semibold,
                    design: .monospaced
                )
            )

            Text("This workspace is not connected yet.")
                .font(
                    .system(
                        size: 17,
                        weight: .medium
                    )
                )
                .foregroundStyle(LurewakeTheme.parchment)

            Text(nextStep)
                .font(.system(size: 14))
                .foregroundStyle(
                    LurewakeTheme.parchment.opacity(0.65)
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(LurewakeTheme.indigo)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LurewakeTheme.gold.opacity(0.18),
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    AppShellView()
}
