import SwiftUI

/// Labeled input matching the handoff: bg #0C2312, 1px lime border, radius 14,
/// 14px padding, green focus ring.
struct GBTextField: View {
    let label: String
    var optional: Bool = false
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Text(label.uppercased())
                    .font(GBFont.semibold(12))
                    .tracking(0.4)
                    .foregroundColor(GBColor.cream(0.7))
                if optional {
                    Text("· optional")
                        .font(GBFont.regular(12))
                        .foregroundColor(GBColor.cream(0.4))
                }
            }
            TextField("", text: $text)
                .font(GBFont.regular(16))
                .foregroundColor(GBColor.textPrimary)
                .tint(GBColor.statusLime)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .focused($focused)
                .padding(14)
                .background(GBColor.bgSecondary,
                            in: RoundedRectangle(cornerRadius: GBRadius.input, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: GBRadius.input, style: .continuous)
                        .strokeBorder(
                            focused ? GBColor.brandGreen : GBColor.lightEmerald.opacity(0.2),
                            lineWidth: focused ? 1.5 : 1)
                )
                .animation(.easeOut(duration: 0.15), value: focused)
        }
    }
}
