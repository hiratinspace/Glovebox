import SwiftUI

/// Screen 10 — Help sheet ("I need help now"). One-tap actions, works without signal.
/// Reachable from anywhere. Built early because many screens present it.
struct HelpSheetView: View {
    /// Invoked by "See saved help nearby" → the Emergency screen.
    var onSeeSavedHelp: () -> Void = {}

    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    /// TODO(Phase 4): source from the last cached Travel-Mode location.
    private let lastCachedSpot = "Exit 42, US-40, Grand County, CO"
    /// TODO(Phase 1/3): roadside number should come from the cached resource set.
    private let roadsideNumber = "+18005550199"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Get help now").gbText(.display)
            Text("One tap. Works without signal.")
                .gbText(.body, color: GBColor.cream(0.6))
                .padding(.top, GBSpace.xxs)

            actionRow(
                title: "Call 911", subtitle: "Life-threatening emergencies only",
                symbol: "phone.fill", style: .hazard
            ) { call("911") }
            .padding(.top, GBSpace.md + 2)

            actionRow(
                title: "Roadside assistance", subtitle: "Towing & lockout · 24/7",
                symbol: "box.truck.fill", style: .primary
            ) { call(roadsideNumber) }
            .padding(.top, GBSpace.sm - 1)

            actionRow(
                title: "Text my location", subtitle: "Pre-filled with your last cached spot",
                symbol: "message.fill", style: .secondary
            ) { textLocation() }
            .padding(.top, GBSpace.sm - 1)

            Button { dismiss(); onSeeSavedHelp() } label: {
                Text("See saved help nearby")
                    .gbText(.buttonSecondary, color: GBColor.statusLime)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, GBSpace.md - 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: GBRadius.button, style: .continuous)
                            .strokeBorder(GBColor.lightEmerald.opacity(0.25), lineWidth: 1)
                    )
            }
            .padding(.top, GBSpace.sm - 1)
        }
        .padding(.horizontal, GBSpace.lg - 2)
        .padding(.top, GBSpace.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private enum RowStyle { case hazard, primary, secondary }

    @ViewBuilder
    private func actionRow(title: String, subtitle: String, symbol: String,
                           style: RowStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: GBSpace.md - 2) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor(style))
                    .frame(width: 42, height: 42)
                    .background(iconBackground(style), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(GBFont.bold(17)).foregroundColor(titleColor(style))
                    Text(subtitle).font(GBFont.regular(12)).foregroundColor(subtitleColor(style))
                }
                Spacer(minLength: 0)
            }
            .padding(GBSpace.md)
            .background(rowBackground(style),
                        in: RoundedRectangle(cornerRadius: GBRadius.button, style: .continuous))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: GBRadius.button, style: .continuous)
                        .strokeBorder(GBColor.cream(0.16), lineWidth: 1)
                }
            }
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: Per-style coloring
    private func rowBackground(_ s: RowStyle) -> AnyShapeStyle {
        switch s {
        case .hazard:    return AnyShapeStyle(GBColor.warning)
        case .primary:   return AnyShapeStyle(GBGradient.limeBadge)
        case .secondary: return AnyShapeStyle(GBColor.cream(0.06))
        }
    }
    private func titleColor(_ s: RowStyle) -> Color {
        switch s { case .hazard: return .white; case .primary: return GBColor.onLime; case .secondary: return GBColor.textPrimary }
    }
    private func subtitleColor(_ s: RowStyle) -> Color {
        switch s { case .hazard: return .white.opacity(0.8); case .primary: return GBColor.onLime.opacity(0.75); case .secondary: return GBColor.cream(0.6) }
    }
    private func iconColor(_ s: RowStyle) -> Color {
        switch s { case .hazard: return .white; case .primary: return GBColor.onLime; case .secondary: return GBColor.textPrimary }
    }
    private func iconBackground(_ s: RowStyle) -> Color {
        switch s { case .hazard: return .white.opacity(0.2); case .primary: return GBColor.onLime.opacity(0.18); case .secondary: return GBColor.cream(0.08) }
    }

    // MARK: Actions
    private func call(_ number: String) {
        if let url = URL(string: "tel:\(number)") { openURL(url) }
    }
    private func textLocation() {
        let body = "I need help. Approx location: \(lastCachedSpot) (cached)."
        let encoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "sms:\(roadsideNumber)&body=\(encoded)") { openURL(url) }
    }
}

#Preview { HelpSheetView().preferredColorScheme(.dark) }
