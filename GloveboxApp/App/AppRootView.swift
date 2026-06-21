import SwiftUI
import SwiftData

/// Top-level routing. Onboarding (welcome → addVehicle → sync) runs only until a
/// vehicle exists; thereafter the app opens straight into the main tab shell.
/// State is derived from persisted SwiftData, so it survives relaunch.
struct AppRootView: View {
    enum Route { case welcome, addVehicle, sync, main }

    @Environment(\.modelContext) private var context
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]

    @State private var route: Route = .welcome
    @State private var didInit = false

    private var activeVehicle: Vehicle? {
        vehicles.first(where: { $0.isActive }) ?? vehicles.last
    }

    var body: some View {
        ZStack {
            GBColor.bgPrimary.ignoresSafeArea()
            content.transition(.opacity)
        }
        .animation(.easeOut(duration: 0.25), value: route)
        .onAppear {
            guard !didInit else { return }
            seedCacheIfNeeded()
            #if DEBUG
            if applyDebugRoute() { didInit = true; return }
            #endif
            route = vehicles.isEmpty ? .welcome : .main
            didInit = true
        }
    }

    /// Seed the placeholder roadside-help cache so the always-reachable Emergency
    /// screen is genuinely backed by on-device data. Replaced by Travel Mode's
    /// real MKLocalSearch cache in Phase 4.
    private func seedCacheIfNeeded() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["GB_EMPTY_CACHE"] == "1" { return }
        #endif
        PlaceholderPOIData.seedIfEmpty(in: context)
    }

    #if DEBUG
    /// Dev-only: jump to a screen via GB_ROUTE env, seeding a vehicle when the
    /// target screen needs one. Used for screenshot verification only.
    private func applyDebugRoute() -> Bool {
        guard let forced = ProcessInfo.processInfo.environment["GB_ROUTE"] else { return false }
        func ensureVehicle(ready: Bool) {
            if vehicles.isEmpty {
                let v = VehicleStore.add(year: "2021", make: "Toyota", model: "RAV4",
                                         trim: "XLE AWD", in: context)
                if ready {
                    PlaceholderManualData.makeChunks(for: v, in: context)
                    v.cacheBytes = PlaceholderManualData.approximateCacheBytes(for: v.manualChunks)
                    v.ready = true
                    v.syncedAt = Date()
                    try? context.save()
                }
            }
        }
        switch forced {
        case "welcome":    route = .welcome
        case "addVehicle": route = .addVehicle
        case "sync":       ensureVehicle(ready: false); route = .sync
        case "syncDone":   ensureVehicle(ready: true);  route = .sync
        case "main":       ensureVehicle(ready: true);  route = .main
        default:           return false
        }
        return true
    }
    #endif

    @ViewBuilder
    private var content: some View {
        switch route {
        case .welcome:
            WelcomeView(onGetStarted: { route = .addVehicle })
        case .addVehicle:
            AddVehicleView(onSaved: { _ in route = .sync })
        case .sync:
            if let vehicle = activeVehicle {
                SyncView(vehicle: vehicle, onEnter: { route = .main })
            } else {
                // Shouldn't happen (save creates an active vehicle); recover gracefully.
                WelcomeView(onGetStarted: { route = .addVehicle })
            }
        case .main:
            MainTabView()
        }
    }
}
