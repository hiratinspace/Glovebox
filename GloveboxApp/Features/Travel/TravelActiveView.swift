import SwiftUI
import MapKit
import SwiftData

/// Screen 8 — Travel Mode Active. Shows resources being cached along the route.
struct TravelActiveView: View {
    @Environment(TravelService.self) private var travel
    @Environment(AppRouter.self) private var router
    @Query private var pois: [CachedPOI]

    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)

    private var mappable: [CachedPOI] { pois.filter { $0.latitude != 0 || $0.longitude != 0 } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                Text("Caching the road ahead near you.")
                    .gbText(.body, color: GBColor.cream(0.55))
                    .padding(.top, GBSpace.xxs + 2)

                mapCard.padding(.top, GBSpace.md)
                cachingStatus.padding(.top, GBSpace.md - 2)
                countsGrid.padding(.top, GBSpace.md)

                PrimaryButton(title: "View saved help nearby") { router.openEmergency() }
                    .padding(.top, GBSpace.md + 2)
            }
            .padding(.horizontal, GBSpace.lg - 2)
            .padding(.top, GBSpace.xxl)
            .padding(.bottom, GBSpace.xxl)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        HStack(spacing: GBSpace.xs + 2) {
            Text("Travel Mode").font(GBFont.extrabold(26)).tracking(-0.52).foregroundColor(GBColor.textPrimary)
            Text("ON")
                .font(GBFont.bold(11)).tracking(0.6).foregroundColor(GBColor.onLime)
                .padding(.horizontal, 11).padding(.vertical, 5)
                .background(GBColor.statusLime, in: Capsule())
                .gbLimeGlow()
            Spacer()
        }
    }

    private var mapCard: some View {
        Map(position: $camera) {
            UserAnnotation()
            ForEach(mappable) { poi in
                Marker(poi.name, systemImage: poi.category.symbol,
                       coordinate: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude))
                    .tint(GBColor.statusLime)
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: GBRadius.large, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: GBRadius.large, style: .continuous)
            .strokeBorder(GBColor.lightEmerald.opacity(0.16), lineWidth: 1))
        .overlay(alignment: .bottomLeading) {
            Text("You · trailing data auto-cleared")
                .font(GBFont.semibold(11)).foregroundColor(GBColor.cream(0.7))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(GBColor.bgPrimary.opacity(0.6), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(10)
        }
    }

    private var cachingStatus: some View {
        HStack(spacing: 9) {
            Circle().fill(GBColor.statusLime).frame(width: 9, height: 9)
                .gbLimeGlow()
                .gbPulse(duration: travel.isCaching ? 1.0 : 1.8)
            Text(travel.isCaching ? "Caching ahead" : "Saved offline")
                .font(GBFont.semibold(14)).foregroundColor(GBColor.textPrimary)
            if let updated = travel.lastUpdated {
                Text("· updated \(RelativeTime.short(updated))")
                    .font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.5))
            } else {
                Text("· waiting for location")
                    .font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.5))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .background(GBColor.lightEmerald.opacity(0.08), in: RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous))
    }

    private var countsGrid: some View {
        let items: [(String, String)] = [
            ("Mechanics", "\(travel.counts[.mechanic] ?? 0)"),
            ("Fuel & EV", "\(travel.counts[.fuel] ?? 0)"),
            ("Hospitals", "\(travel.counts[.hospital] ?? 0)"),
            ("Towing",    "\(travel.counts[.towing] ?? 0)"),
            ("Police",    "\(travel.counts[.police] ?? 0)"),
            ("Storage",   byteLabel(travel.cachedBytes)),
        ]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(items, id: \.0) { label, value in
                VStack(spacing: 2) {
                    Text(value).font(GBFont.extrabold(22)).foregroundColor(GBColor.statusLime)
                    Text(label.uppercased()).font(GBFont.semibold(11)).tracking(0.3)
                        .foregroundColor(GBColor.cream(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(GBGradient.tile, in: RoundedRectangle(cornerRadius: GBRadius.input, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: GBRadius.input, style: .continuous)
                    .strokeBorder(GBColor.lightEmerald.opacity(0.13), lineWidth: 1))
            }
        }
    }

    private func byteLabel(_ bytes: Int) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        let kb = Double(bytes) / 1024
        if kb < 1024 { return String(format: "%.0f KB", kb) }
        return String(format: "%.1f MB", kb / 1024)
    }
}
