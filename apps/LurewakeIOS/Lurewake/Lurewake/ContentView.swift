
import SwiftUI

private enum LWPalette {
    static let ink = Color(
        red: 18.0 / 255.0,
        green: 24.0 / 255.0,
        blue: 39.0 / 255.0
    )

    static let indigo = Color(
        red: 32.0 / 255.0,
        green: 41.0 / 255.0,
        blue: 60.0 / 255.0
    )

    static let parchment = Color(
        red: 244.0 / 255.0,
        green: 240.0 / 255.0,
        blue: 231.0 / 255.0
    )

    static let gold = Color(
        red: 228.0 / 255.0,
        green: 184.0 / 255.0,
        blue: 117.0 / 255.0
    )

    static let teal = Color(
        red: 114.0 / 255.0,
        green: 191.0 / 255.0,
        blue: 174.0 / 255.0
    )
}

struct ContentView: View {
    var body: some View {
        ZStack {
            LWPalette.ink
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    LWPalette.indigo,
                    LWPalette.ink
                ],
                center: .top,
                startRadius: 20,
                endRadius: 520
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    MothMark()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 46)
                        .padding(.bottom, 32)

                    Text("lurewake")
                        .font(
                            .system(
                                size: 54,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .tracking(-2.5)
                        .foregroundStyle(LWPalette.parchment)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text(
                        "Plant the lure.\n" +
                        "Follow the wake.\n" +
                        "Prove the signal."
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .light
                        )
                    )
                    .foregroundStyle(LWPalette.gold)
                    .lineSpacing(5)
                    .padding(.top, 18)

                    Rectangle()
                        .fill(LWPalette.gold.opacity(0.35))
                        .frame(height: 1)
                        .padding(.vertical, 30)

                    foundationCard

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(LWPalette.teal)

                        Text("Native SwiftUI foundation")
                            .foregroundStyle(
                                LWPalette.parchment.opacity(0.65)
                            )
                    }
                    .font(.system(size: 12))
                    .padding(.top, 26)
                }
                .padding(.horizontal, 26)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 9) {
            Circle()
                .fill(LWPalette.gold)
                .frame(width: 7, height: 7)

            Text("FIELD OBSERVATORY")
                .tracking(1.5)

            Spacer()

            Text("PREP / 00")
                .tracking(1)
        }
        .font(
            .system(
                size: 10,
                weight: .semibold,
                design: .monospaced
            )
        )
        .foregroundStyle(
            LWPalette.parchment.opacity(0.65)
        )
    }

    private var foundationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "circle.dotted")
                    .foregroundStyle(LWPalette.gold)

                Text("LOCAL FOUNDATION")
                    .tracking(1.3)
                    .foregroundStyle(LWPalette.gold)
            }
            .font(
                .system(
                    size: 11,
                    weight: .semibold,
                    design: .monospaced
                )
            )

            Text("The observatory is taking shape.")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(LWPalette.parchment)

            Text(
                "The native app is running. Lure issuance, " +
                "event collection, and detection proof " +
                "are not connected yet."
            )
            .font(.system(size: 14))
            .foregroundStyle(
                LWPalette.parchment.opacity(0.65)
            )
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(LWPalette.indigo.opacity(0.85))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LWPalette.gold.opacity(0.18),
                    lineWidth: 1
                )
        }
    }
}

private struct MothMark: View {
    private var wingGradient: LinearGradient {
        LinearGradient(
            colors: [
                LWPalette.gold,
                LWPalette.gold.opacity(0.55)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LWPalette.gold.opacity(0.16),
                    lineWidth: 1
                )
                .frame(width: 214, height: 214)

            Circle()
                .stroke(
                    LWPalette.gold.opacity(0.22),
                    style: StrokeStyle(
                        lineWidth: 1,
                        dash: [2, 7]
                    )
                )
                .frame(width: 166, height: 166)

            Ellipse()
                .fill(wingGradient)
                .frame(width: 66, height: 98)
                .rotationEffect(.degrees(-38))
                .offset(x: -40, y: -26)

            Ellipse()
                .fill(wingGradient)
                .frame(width: 66, height: 98)
                .rotationEffect(.degrees(38))
                .offset(x: 40, y: -26)

            Ellipse()
                .fill(wingGradient)
                .frame(width: 48, height: 70)
                .rotationEffect(.degrees(25))
                .offset(x: -32, y: 43)

            Ellipse()
                .fill(wingGradient)
                .frame(width: 48, height: 70)
                .rotationEffect(.degrees(-25))
                .offset(x: 32, y: 43)

            Capsule()
                .fill(LWPalette.gold)
                .frame(width: 12, height: 88)
                .offset(y: 8)

            Circle()
                .fill(LWPalette.parchment)
                .frame(width: 12, height: 12)
                .offset(y: -40)
        }
        .frame(width: 230, height: 230)
        .shadow(
            color: LWPalette.gold.opacity(0.12),
            radius: 20
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Lurewake moth emblem")
    }
}

#Preview {
    ContentView()
}
