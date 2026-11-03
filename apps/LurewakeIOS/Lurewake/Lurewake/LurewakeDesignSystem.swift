
import SwiftUI

// MARK: - Lurewake Design Tokens

enum LurewakeTheme {

    // MARK: Colors

    static let ink = Color(
        red: 18.0 / 255,
        green: 24.0 / 255,
        blue: 39.0 / 255
    )

    static let indigo = Color(
        red: 32.0 / 255,
        green: 41.0 / 255,
        blue: 60.0 / 255
    )

    static let gold = Color(
        red: 228.0 / 255,
        green: 184.0 / 255,
        blue: 117.0 / 255
    )

    static let parchment = Color(
        red: 244.0 / 255,
        green: 240.0 / 255,
        blue: 231.0 / 255
    )

    static let mist = Color(
        red: 97.0 / 255,
        green: 127.0 / 255,
        blue: 136.0 / 255
    )

    static let mutedText = parchment.opacity(0.65)
    static let subtleBorder = gold.opacity(0.18)

    // MARK: Layout

    static let screenPadding: CGFloat = 26
    static let cardPadding: CGFloat = 20
    static let cardRadius: CGFloat = 18

    // MARK: Typography

    static let eyebrowFont = Font.system(
        size: 10,
        weight: .semibold,
        design: .monospaced
    )

    static let pageTitleFont = Font.system(
        size: 48,
        weight: .semibold,
        design: .rounded
    )

    static let bodyFont = Font.system(
        size: 16,
        weight: .regular
    )
}

// MARK: - Reusable Observatory Panel

struct LurewakePanel<Content: View>: View {

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(LurewakeTheme.cardPadding)
            .background {
                RoundedRectangle(
                    cornerRadius: LurewakeTheme.cardRadius
                )
                .fill(LurewakeTheme.indigo)
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: LurewakeTheme.cardRadius
                )
                .stroke(
                    LurewakeTheme.subtleBorder,
                    lineWidth: 1
                )
            }
    }
}

// MARK: - Reusable Section Label

struct LurewakeEyebrow: View {

    let title: String

    var body: some View {
        HStack(spacing: 9) {
            Circle()
                .fill(LurewakeTheme.gold)
                .frame(width: 6, height: 6)

            Text(title.uppercased())
                .font(LurewakeTheme.eyebrowFont)
                .tracking(1.2)
                .foregroundStyle(LurewakeTheme.gold)
        }
    }
}

// MARK: - Preview

#Preview("Lurewake Design System") {
    ZStack {
        LurewakeTheme.ink
            .ignoresSafeArea()

        VStack(spacing: 20) {

            LurewakeEyebrow(
                title: "Field Observatory"
            )

            LurewakePanel {
                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {
                    Text("Signal foundation")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(
                            LurewakeTheme.parchment
                        )

                    Text(
                        "Shared visual components " +
                        "for the Lurewake observatory."
                    )
                    .font(LurewakeTheme.bodyFont)
                    .foregroundStyle(
                        LurewakeTheme.mutedText
                    )
                }
            }
        }
        .padding(LurewakeTheme.screenPadding)
    }
    .preferredColorScheme(.dark)
}
