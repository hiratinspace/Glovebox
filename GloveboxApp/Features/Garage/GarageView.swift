import SwiftUI
import SwiftData

/// Screen 5 — Garage. Manage multiple vehicles; switch active; re-sync.
struct GarageView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]

    @State private var presented: Presentation?

    private enum Presentation: Identifiable {
        case add
        case resync(Vehicle)
        var id: String {
            switch self {
            case .add: return "add"
            case .resync(let v): return v.id.uuidString
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Garage").gbText(.display)
                Text("Switch the active vehicle or re-sync its cache.")
                    .gbText(.body, color: GBColor.cream(0.55))
                    .padding(.top, GBSpace.xxs + 2)

                VStack(spacing: GBSpace.md - 2) {
                    ForEach(vehicles) { vehicle in
                        vehicleCard(vehicle)
                    }
                }
                .padding(.top, GBSpace.md + 2)

                addButton.padding(.top, GBSpace.md)
            }
            .padding(.horizontal, GBSpace.lg - 2)
            .padding(.top, GBSpace.xxl)
            .padding(.bottom, GBSpace.xxl)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fullScreenCover(item: $presented) { item in
            switch item {
            case .add:
                AddVehicleFlow(onFinish: { presented = nil })
            case .resync(let vehicle):
                ZStack {
                    GBColor.bgPrimary.ignoresSafeArea()
                    SyncView(vehicle: vehicle, onEnter: { presented = nil }, enterTitle: "Done")
                }
            }
        }
    }

    // MARK: Vehicle card
    private func vehicleCard(_ v: Vehicle) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(v.displayName).gbText(.cardTitle)
                    if !v.trim.isEmpty {
                        Text(v.trim).font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.55))
                    }
                }
                Spacer()
                if v.isActive {
                    Text("ACTIVE")
                        .font(GBFont.bold(10)).tracking(0.8)
                        .foregroundColor(GBColor.onLime)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(GBColor.statusLime, in: Capsule())
                }
            }

            statusLine(v).padding(.top, GBSpace.sm)

            HStack(spacing: GBSpace.sm - 2) {
                if !v.isActive {
                    cardButton(title: "Set active", tint: GBColor.statusLime,
                               bg: GBColor.lightEmerald.opacity(0.14),
                               border: GBColor.lightEmerald.opacity(0.3)) {
                        VehicleStore.setActive(v, in: context)
                    }
                }
                cardButton(title: "Re-sync", tint: GBColor.textPrimary,
                           bg: GBColor.cream(0.06), border: GBColor.cream(0.16)) {
                    startResync(v)
                }
            }
            .padding(.top, GBSpace.md - 2)
        }
        .padding(GBSpace.md + 2)
        .gbCard(radius: GBRadius.large)
    }

    @ViewBuilder
    private func statusLine(_ v: Vehicle) -> some View {
        if v.ready {
            HStack(spacing: GBSpace.xs) {
                Text("● Ready offline").font(GBFont.semibold(13)).foregroundColor(GBColor.statusLime)
                Text("synced \(v.syncedAt.map { RelativeTime.short($0) } ?? "—")")
                    .font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.45))
            }
        } else {
            Text("Not cached yet").font(GBFont.semibold(13)).foregroundColor(GBColor.alertTextAlt)
        }
    }

    private func cardButton(title: String, tint: Color, bg: Color, border: Color,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(GBFont.semibold(14)).foregroundColor(tint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(bg, in: RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous)
                    .strokeBorder(border, lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var addButton: some View {
        Button { presented = .add } label: {
            HStack(spacing: GBSpace.xs) {
                Image(systemName: "plus").font(.system(size: 16, weight: .bold))
                Text("Add a vehicle").font(GBFont.semibold(15))
            }
            .foregroundColor(GBColor.statusLime)
            .frame(maxWidth: .infinity)
            .padding(.vertical, GBSpace.md)
            .overlay(RoundedRectangle(cornerRadius: GBRadius.card, style: .continuous)
                .strokeBorder(GBColor.lightEmerald.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func startResync(_ v: Vehicle) {
        VehicleStore.setActive(v, in: context)
        v.ready = false          // force a fresh sync on the Sync screen
        try? context.save()
        presented = .resync(v)
    }
}
