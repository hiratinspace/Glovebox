import SwiftUI

/// Screen 1 — Welcome (onboarding). Hero-gradient full screen.
struct WelcomeView: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            GBGradient.hero.ignoresSafeArea()

            VStack {
                Spacer(minLength: GBSpace.xxl)

                VStack(spacing: 0) {
                    Image("BrandIcon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: GBRadius.icon, style: .continuous))
                        .gbBreathing()

                    Text("Glovebox")
                        .gbText(.wordmark)
                        .padding(.top, GBSpace.lg + 2)

                    Text("Everything you need is already with you.")
                        .font(GBFont.semibold(21))
                        .foregroundColor(GBColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .frame(maxWidth: 280)
                        .padding(.top, GBSpace.sm + 2)

                    Text("Diagnose car trouble and reach roadside help — even with no signal, low battery, and miles from the nearest bar.")
                        .gbText(.body, color: GBColor.cream(0.6))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 290)
                        .padding(.top, GBSpace.sm + 2)
                }

                Spacer()

                VStack(spacing: GBSpace.sm + 2) {
                    PrimaryButton(title: "Get started", action: onGetStarted)
                    Text("First setup needs a connection. After that, it works offline.")
                        .font(GBFont.regular(12))
                        .foregroundColor(GBColor.cream(0.45))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, GBSpace.xxl)
            .padding(.bottom, GBSpace.xl + GBSpace.sm)
        }
    }
}

#Preview { WelcomeView(onGetStarted: {}) }
