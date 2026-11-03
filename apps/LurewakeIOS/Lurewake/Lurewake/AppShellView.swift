
import SwiftUI

private enum ShellColors {
    static let ink = Color(
        red: 18 / 255,
        green: 24 / 255,
        blue: 39 / 255
    )

    static let indigo = Color(
        red: 32 / 255,
        green: 41 / 255,
        blue: 60 / 255
    )

    static let gold = Color(
        red: 228 / 255,
        green: 184 / 255,
        blue: 117 / 255
    )

    static let parchment = Color(
        red: 244 / 255,
        green: 240 / 255,
        blue: 231 / 255
    )
}

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
        .tint(ShellColors.gold)
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
            ShellColors.ink
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    ShellColors.indigo,
                    ShellColors.ink
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
                        .foregroundStyle(ShellColors.gold)
                        .frame(width: 122, height: 122)
                        .background {
                            Circle()
                                .fill(ShellColors.indigo)
                        }
                        .overlay {
                            Circle()
                                .stroke(
                                    ShellColors.gold.opacity(0.3),
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
                            ShellColors.parchment
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
                            ShellColors.parchment.opacity(0.75)
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .padding(.top, 16)

                    Rectangle()
                        .fill(
                            ShellColors.gold.opacity(0.3)
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
                .fill(ShellColors.gold)
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
            ShellColors.parchment.opacity(0.65)
        )
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 9) {
                Image(systemName: "circle.dotted")
                    .foregroundStyle(ShellColors.gold)

                Text("AWAITING IMPLEMENTATION")
                    .tracking(1)
                    .foregroundStyle(ShellColors.gold)
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
                .foregroundStyle(ShellColors.parchment)

            Text(nextStep)
                .font(.system(size: 14))
                .foregroundStyle(
                    ShellColors.parchment.opacity(0.65)
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
                .fill(ShellColors.indigo)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    ShellColors.gold.opacity(0.18),
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    AppShellView()
}
