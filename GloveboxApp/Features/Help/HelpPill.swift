import SwiftUI

/// Floating rust "Help" pill — a one-tap emergency path reachable from anywhere.
/// Rust is RESERVED for genuine emergencies; this is one of the sanctioned uses.
struct HelpPill: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: GBSpace.xs) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("Help")
                    .font(GBFont.bold(14))
            }
            .foregroundColor(.white)
            .padding(.horizontal, GBSpace.md)
            .padding(.vertical, GBSpace.sm)
            .background(GBColor.warning, in: Capsule())
            .shadow(color: GBColor.warning.opacity(0.5), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Get help now")
    }
}
