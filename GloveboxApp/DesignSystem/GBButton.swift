import SwiftUI

/// Primary CTA: lime→green gradient, dark text, soft green glow.
/// Buttons: 16px / weight 700.
struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: GBSpace.xs) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .gbText(.buttonPrimary, color: GBColor.onPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, GBSpace.md)
            .background(GBGradient.primaryButton,
                        in: RoundedRectangle(cornerRadius: GBRadius.button, style: .continuous))
            .gbPrimaryGlow()
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Secondary button: translucent cream fill, hairline border.
struct SecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: GBSpace.xs) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .gbText(.buttonSecondary, color: GBColor.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, GBSpace.md)
            .background(GBColor.cream(0.06),
                        in: RoundedRectangle(cornerRadius: GBRadius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GBRadius.button, style: .continuous)
                    .strokeBorder(GBColor.cream(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Hover ≈ scale(1.02); on touch we use a gentle press scale. Respects Reduce Motion.
struct PressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
