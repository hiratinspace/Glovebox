import SwiftUI
import SwiftData

/// Screen 9 — Emergency (offline help), always reachable. Reads from the on-device
/// POI cache; never silently requires network. Every item shows a visible
/// staleness label so stale data never looks fresh.
struct EmergencyView: View {
    var onClose: () -> Void

    @Environment(NetworkMonitor.self) private var network
    @Query(sort: \CachedPOI.distanceMiles) private var pois: [CachedPOI]

    @State private var showHelp = false
    private var online: Bool { network.isOnline }

    var body: some View {
        VStack(spacing: 0) {
            header
            content
            footer
        }
        .background(GBColor.bgPrimary.ignoresSafeArea())
        .sheet(isPresented: $showHelp) {
            HelpSheetView(onSeeSavedHelp: { showHelp = false }) // already here
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(GBColor.bgPrimary)
        }
    }

    // MARK: Header + banner
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: GBSpace.xs) {
                BackButton(action: onClose)
                Text("Help nearby").font(GBFont.extrabold(20)).foregroundColor(GBColor.textPrimary)
            }
            banner.padding(.top, GBSpace.sm)
        }
        .padding(.horizontal, GBSpace.md + 2)
        .padding(.top, GBSpace.xs)
        .padding(.bottom, GBSpace.sm)
    }

    @ViewBuilder
    private var banner: some View {
        if online {
            HStack(spacing: GBSpace.xs + 2) {
                Image(systemName: "wifi").font(.system(size: 14, weight: .bold))
                    .foregroundColor(GBColor.statusLime)
                Text("Saved for offline · works even with no signal")
                    .font(GBFont.semibold(13)).foregroundColor(GBColor.statusLime)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(GBColor.lightEmerald.opacity(0.08), in: RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous))
        } else {
            HStack(spacing: GBSpace.xs + 2) {
                Circle().fill(GBColor.warning).frame(width: 9, height: 9).gbPulse(duration: 1.4)
                Text("You're offline — showing saved help")
                    .font(GBFont.bold(13)).foregroundColor(GBColor.alertText)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(GBColor.warning.opacity(0.16), in: RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous)
                .strokeBorder(GBColor.warning.opacity(0.5), lineWidth: 1))
        }
    }

    // MARK: Content
    @ViewBuilder
    private var content: some View {
        if pois.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Sorted by distance · cached near \(nearestLocation)")
                        .font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.5))
                        .padding(.bottom, GBSpace.sm)
                    VStack(spacing: GBSpace.sm) {
                        ForEach(pois) { poi in POICard(poi: poi) }
                    }
                }
                .padding(.horizontal, GBSpace.md + 2)
                .padding(.top, GBSpace.xxs)
                .padding(.bottom, GBSpace.lg)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle().fill(GBColor.cream(0.06)).frame(width: 64, height: 64)
                Image(systemName: "mappin.slash")
                    .font(.system(size: 26, weight: .semibold)).foregroundColor(GBColor.cream(0.5))
            }
            Text("Nothing cached for this area yet").gbText(.cardTitle).padding(.top, GBSpace.md)
            Text("Travel Mode hasn't saved help for where you are now. If you have any signal, reconnect to pull nearby options — otherwise dial 911 directly below.")
                .gbText(.body, color: GBColor.cream(0.6))
                .multilineTextAlignment(.center)
                .padding(.top, GBSpace.xs)
            Button { showHelp = true } label: {
                Text("Open emergency dialer")
                    .font(GBFont.bold(15)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(GBColor.warning, in: RoundedRectangle(cornerRadius: GBRadius.input, style: .continuous))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, GBSpace.md + 2)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, GBSpace.lg)
    }

    // MARK: Footer — sticky rust "I need help now"
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().overlay(GBColor.warning.opacity(0.25))
            Button { showHelp = true } label: {
                HStack(spacing: GBSpace.xs + 1) {
                    Image(systemName: "phone.fill").font(.system(size: 17, weight: .bold))
                    Text("I need help now").font(GBFont.bold(16))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 15)
                .background(GBColor.warning, in: RoundedRectangle(cornerRadius: GBRadius.button, style: .continuous))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, GBSpace.md + 2)
            .padding(.top, GBSpace.sm)
            .padding(.bottom, GBSpace.xs)
        }
        .background(GBColor.bgPrimary)
    }

    private var nearestLocation: String {
        pois.first(where: { !$0.locationLabel.isEmpty })?.locationLabel ?? "your last location"
    }
}

/// A single cached-help card with one-tap Call / pre-filled Text.
struct POICard: View {
    let poi: CachedPOI
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: GBSpace.sm + 1) {
                Image(systemName: poi.category.symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(GBColor.statusLime)
                    .frame(width: 44, height: 44)
                    .background(GBColor.lightEmerald.opacity(0.12), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                VStack(alignment: .leading, spacing: 1) {
                    Text(poi.typeLabel.uppercased())
                        .font(GBFont.bold(10)).tracking(0.7).foregroundColor(GBColor.cream(0.5))
                    Text(poi.name).font(GBFont.bold(16)).foregroundColor(GBColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: GBSpace.xs)
                Text(poi.distanceLabel)
                    .font(GBFont.extrabold(19)).foregroundColor(GBColor.statusLime)
            }

            HStack(spacing: 6) {
                let stale = poi.isStale()
                Image(systemName: "clock")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(stale ? GBColor.alertText : GBColor.cream(0.5))
                Text(poi.stalenessLabel())
                    .font(stale ? GBFont.semibold(12) : GBFont.regular(12))
                    .foregroundColor(stale ? GBColor.alertText : GBColor.cream(0.55))
            }
            .padding(.top, GBSpace.sm - 1)

            HStack(spacing: GBSpace.sm - 2) {
                Button { if let u = poi.telURL { openURL(u) } } label: {
                    actionLabel(symbol: "phone.fill", title: "Call", primary: true)
                }.buttonStyle(PressableButtonStyle())
                Button { if let u = poi.smsURL { openURL(u) } } label: {
                    actionLabel(symbol: "message.fill", title: "Text", primary: false)
                }.buttonStyle(PressableButtonStyle())
            }
            .padding(.top, GBSpace.sm + 1)
        }
        .padding(GBSpace.md - 1)
        .gbCard(radius: GBRadius.card, borderOpacity: 0.15)
    }

    private func actionLabel(symbol: String, title: String, primary: Bool) -> some View {
        HStack(spacing: 7) {
            Image(systemName: symbol).font(.system(size: 14, weight: .bold))
            Text(title).font(primary ? GBFont.bold(14) : GBFont.semibold(14))
        }
        .foregroundColor(primary ? GBColor.onLime : GBColor.textPrimary)
        .frame(maxWidth: .infinity).padding(.vertical, 11)
        .background(
            primary ? AnyShapeStyle(GBGradient.limeBadge) : AnyShapeStyle(GBColor.cream(0.06)),
            in: RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous)
        )
        .overlay {
            if !primary {
                RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous)
                    .strokeBorder(GBColor.cream(0.16), lineWidth: 1)
            }
        }
    }
}
