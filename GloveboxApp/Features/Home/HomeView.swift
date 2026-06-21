import SwiftUI
import SwiftData

/// Screen 4 — Home. Hub: active-vehicle status + quick actions + always-present
/// emergency entry.
struct HomeView: View {
    var onSelectTab: (AppTab) -> Void

    @Environment(AppRouter.self) private var router
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]

    private var active: Vehicle? { vehicles.first(where: { $0.isActive }) ?? vehicles.last }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Good to go.")
                    .font(GBFont.medium(13))
                    .foregroundColor(GBColor.cream(0.6))
                Text("Glovebox").gbText(.display)

                if let active { activeVehicleCard(active).padding(.top, GBSpace.md + 2) }

                actionTiles.padding(.top, GBSpace.md)

                Text("If something goes wrong")
                    .gbText(.label, color: GBColor.cream(0.4))
                    .padding(.top, GBSpace.md + 2)
                helpButton.padding(.top, GBSpace.xs + 2)
            }
            .padding(.horizontal, GBSpace.lg - 2)
            .padding(.top, GBSpace.xxl)
            .padding(.bottom, GBSpace.xxl)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Active vehicle card
    private func activeVehicleCard(_ v: Vehicle) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Active vehicle").gbText(.label, color: GBColor.cream(0.45))
                    Text(v.displayName).gbText(.sectionTitle).padding(.top, 5)
                    if !v.trim.isEmpty {
                        Text(v.trim).font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.55))
                    }
                }
                Spacer()
                Button { onSelectTab(.garage) } label: {
                    Text("Garage")
                        .font(GBFont.semibold(12))
                        .foregroundColor(GBColor.cream(0.8))
                        .padding(.horizontal, 11).padding(.vertical, 7)
                        .background(GBColor.cream(0.07), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(GBColor.cream(0.15), lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
            }
            statusPill(v).padding(.top, GBSpace.md - 2)
        }
        .padding(GBSpace.md + 2)
        .gbCard()
    }

    @ViewBuilder
    private func statusPill(_ v: Vehicle) -> some View {
        if v.ready {
            HStack(spacing: GBSpace.xs) {
                Image(systemName: "checkmark").font(.system(size: 12, weight: .heavy))
                    .foregroundColor(GBColor.statusLime)
                Text("Ready offline").font(GBFont.semibold(13)).foregroundColor(GBColor.statusLime)
                Text("· synced \(syncedLabel(v))").font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.5))
                Spacer(minLength: 0)
            }
            .padding(.horizontal, GBSpace.sm).padding(.vertical, 9)
            .background(GBColor.brandGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            HStack {
                Text("Not cached yet").font(GBFont.semibold(13)).foregroundColor(GBColor.alertTextAlt)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, GBSpace.sm).padding(.vertical, 9)
            .background(GBColor.warning.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: Action tiles
    private var actionTiles: some View {
        HStack(spacing: GBSpace.md - 2) {
            ActionTile(symbol: "wrench.and.screwdriver.fill", title: "Diagnose\na problem") {
                onSelectTab(.diagnose)
            }
            ActionTile(symbol: "point.topleft.down.to.point.bottomright.curvepath", title: "Travel\nMode") {
                onSelectTab(.travel)
            }
        }
    }

    // MARK: Help button
    private var helpButton: some View {
        Button { router.openHelp() } label: {
            HStack(spacing: GBSpace.md - 2) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(GBColor.warning, in: Circle())
                VStack(alignment: .leading, spacing: 1) {
                    Text("I need help now").font(GBFont.bold(16)).foregroundColor(GBColor.textPrimary)
                    Text("One tap — works without signal")
                        .font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.6))
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, GBSpace.md + 2).padding(.vertical, GBSpace.md)
            .background(GBColor.warning.opacity(0.14), in: RoundedRectangle(cornerRadius: GBRadius.card, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: GBRadius.card, style: .continuous)
                .strokeBorder(GBColor.warning.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func syncedLabel(_ v: Vehicle) -> String {
        v.syncedAt.map { RelativeTime.short($0) } ?? "never"
    }
}

/// 128pt-tall quick-action tile.
struct ActionTile: View {
    let symbol: String
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(GBColor.statusLime)
                    .frame(width: 42, height: 42)
                    .background(GBColor.lightEmerald.opacity(0.14), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                Spacer(minLength: GBSpace.sm)
                Text(title)
                    .font(GBFont.bold(16))
                    .foregroundColor(GBColor.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
            .padding(GBSpace.md)
            .background(GBGradient.tile, in: RoundedRectangle(cornerRadius: GBRadius.large, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: GBRadius.large, style: .continuous)
                .strokeBorder(GBColor.lightEmerald.opacity(0.14), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }
}
