import SwiftUI

/// Shadows, glows, and motion from the handoff.
/// Motion: 200–300ms ease-out. Respect Reduce Motion.
enum GBShadow {
    /// Card shadow: 0 8px 32px rgba(0,0,0,0.35)
    static func card(_ view: some View) -> some View {
        view.shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 8)
    }
}

extension View {
    /// Card shadow: 0 8px 32px rgba(0,0,0,0.35)
    func gbCardShadow() -> some View {
        shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 8)
    }

    /// Primary glow: 0 0 20px rgba(76,175,106,.35), 0 0 60px rgba(76,175,106,.15)
    func gbPrimaryGlow() -> some View {
        self
            .shadow(color: GBColor.brandGreen.opacity(0.35), radius: 10)
            .shadow(color: GBColor.brandGreen.opacity(0.15), radius: 30)
    }

    /// Lime status glow: 0 0 12px rgba(164,214,94,.5)
    func gbLimeGlow() -> some View {
        shadow(color: GBColor.statusLime.opacity(0.5), radius: 6)
    }

    /// Standard card container: gradient fill, hairline lime border, radius, shadow.
    func gbCard(radius: CGFloat = GBRadius.xLarge,
                fill: LinearGradient = GBGradient.card,
                borderOpacity: Double = 0.16) -> some View {
        self
            .background(fill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(GBColor.lightEmerald.opacity(borderOpacity), lineWidth: 1)
            )
            .gbCardShadow()
    }
}

/// Breathing glow used on the welcome app icon (`gbBreath` keyframe).
struct BreathingGlow: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var on = false
    func body(content: Content) -> some View {
        content
            .shadow(color: GBColor.brandGreen.opacity(on ? 0.55 : 0.28),
                    radius: on ? 28 : 16)
            .shadow(color: GBColor.brandGreen.opacity(on ? 0.22 : 0.12),
                    radius: on ? 72 : 44)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    on = true
                }
            }
    }
}

/// Offline / alert pulse (`gbPulse`): opacity 1 <-> 0.5.
struct PulseEffect: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dim = false
    var duration: Double = 1.8
    func body(content: Content) -> some View {
        content
            .opacity(dim ? 0.5 : 1.0)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    dim = true
                }
            }
    }
}

extension View {
    func gbBreathing() -> some View { modifier(BreathingGlow()) }
    func gbPulse(duration: Double = 1.8) -> some View { modifier(PulseEffect(duration: duration)) }
}
