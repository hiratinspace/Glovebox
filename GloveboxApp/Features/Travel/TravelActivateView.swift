import SwiftUI
import CoreLocation

/// Screen 7 — Travel Mode Activate. Explains *why* Always-location is needed
/// **before** triggering the iOS prompt.
struct TravelActivateView: View {
    @Environment(TravelService.self) private var travel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(GBColor.lightEmerald.opacity(0.12))
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(GBColor.lightEmerald.opacity(0.25), lineWidth: 1))
                        .frame(width: 84, height: 84)
                    Image(systemName: "location.fill")
                        .font(.system(size: 38, weight: .semibold)).foregroundColor(GBColor.statusLime)
                }

                Text("Turn on Travel Mode").gbText(.pageTitle).padding(.top, GBSpace.lg - 4)
                Text("Glovebox quietly pre-saves roadside help along your route, so it's already on your phone before the signal drops.")
                    .gbText(.body, color: GBColor.cream(0.65))
                    .padding(.top, GBSpace.xs + 2)

                VStack(spacing: GBSpace.md - 2) {
                    benefit("waveform.path.ecg", "Help cached ahead of you",
                            "Mechanics, fuel & EV, hospitals, towing and non-emergency police along the road.")
                    benefit("bolt.heart", "Easy on your battery",
                            "Updates every few miles in the background — not constant high-accuracy GPS.")
                    benefit("lock.shield", "Stays on your phone",
                            "Your location is never shared. Old data behind you is automatically cleared.")
                }
                .padding(.top, GBSpace.lg)

                Text("Next, iOS will ask for “Always Allow” location. That's what lets caching keep working while the app is in your pocket. We're telling you why first — you're always in control.")
                    .gbText(.bodySmall, color: GBColor.cream(0.7))
                    .padding(14)
                    .background(GBColor.lightEmerald.opacity(0.06), in: RoundedRectangle(cornerRadius: GBRadius.input, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: GBRadius.input, style: .continuous)
                        .strokeBorder(GBColor.lightEmerald.opacity(0.16), lineWidth: 1))
                    .padding(.top, GBSpace.lg - 2)

                if travel.authStatus == .denied || travel.authStatus == .restricted {
                    Text("Location access is off. Enable it for Glovebox in Settings to use Travel Mode.")
                        .gbText(.bodySmall, color: GBColor.alertText)
                        .padding(.top, GBSpace.sm)
                }

                PrimaryButton(title: "Enable Travel Mode") { travel.enable() }
                    .padding(.top, GBSpace.lg - 2)
            }
            .padding(.horizontal, GBSpace.lg)
            .padding(.top, GBSpace.xxl)
            .padding(.bottom, GBSpace.xxl)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GBGradient.travelActivate.ignoresSafeArea())
    }

    private func benefit(_ symbol: String, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: GBSpace.sm + 1) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold)).foregroundColor(GBColor.statusLime)
                .frame(width: 34, height: 34)
                .background(GBColor.lightEmerald.opacity(0.12), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(GBFont.semibold(15)).foregroundColor(GBColor.textPrimary)
                Text(body).font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.6)).lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
    }
}
