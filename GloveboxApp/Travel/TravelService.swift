import Foundation
import CoreLocation
import SwiftData
import Observation

/// Travel Mode orchestration: battery-aware location → sliding-window POI cache
/// (current position + ahead) via MKLocalSearch, with eviction of data well
/// behind the user to bound storage. Persists results as `CachedPOI` so the
/// always-reachable Emergency screen reads real, recent help.
@MainActor
@Observable
final class TravelService {
    // Tunables
    private let refreshEveryMeters: CLLocationDistance = 4_800   // ~3 mi between cache refreshes
    private let evictBehindMeters: CLLocationDistance = 64_000   // drop help >~40 mi away
    private let maxCacheAge: TimeInterval = 60 * 60             // and older than 1 hr

    private let context: ModelContext
    private let location = LocationManager()
    private let enabledKey = "travelEnabled"

    private(set) var authStatus: CLAuthorizationStatus
    private(set) var isCaching = false
    private(set) var lastUpdated: Date?
    private(set) var userCoordinate: CLLocationCoordinate2D?
    private(set) var counts: [CachedPOI.Category: Int] = [:]
    private(set) var cachedBytes = 0

    private var lastRefreshLocation: CLLocation?

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    init(context: ModelContext) {
        self.context = context
        self.authStatus = CLLocationManager().authorizationStatus
        location.onAuthChange = { [weak self] status in
            Task { @MainActor in self?.handleAuthChange(status) }
        }
        location.onLocation = { [weak self] loc in
            Task { @MainActor in self?.handleLocation(loc) }
        }
        recomputeCounts()
        if isEnabled { location.start() }
    }

    // MARK: Enable / disable
    func enable() {
        isEnabled = true
        location.requestAuthorization()
        // If already authorized, start immediately.
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            location.start()
            Task { await refreshNow() }
        }
    }

    func disable() {
        isEnabled = false
        location.stop()
    }

    private func handleAuthChange(_ status: CLAuthorizationStatus) {
        authStatus = status
        if isEnabled, status == .authorizedAlways || status == .authorizedWhenInUse {
            location.start()
            Task { await refreshNow() }
        }
    }

    private func handleLocation(_ loc: CLLocation) {
        userCoordinate = loc.coordinate
        // Throttle: only re-cache after moving a few miles (battery-aware).
        if let last = lastRefreshLocation, loc.distance(from: last) < refreshEveryMeters,
           lastUpdated != nil {
            return
        }
        Task { await refresh(around: loc) }
    }

    /// Force a refresh at the current/last known location.
    func refreshNow() async {
        if let loc = location.lastLocation { await refresh(around: loc) }
        else { location.requestOneShot() }
    }

    // MARK: Cache pipeline
    private func refresh(around loc: CLLocation) async {
        guard !isCaching else { return }
        isCaching = true
        defer { isCaching = false }

        let results = await POISearch.search(around: loc.coordinate)
        guard !results.isEmpty else { return } // offline / no results → keep existing cache

        // First real data replaces the labeled placeholders.
        removePlaceholders()

        let existing = (try? context.fetch(FetchDescriptor<CachedPOI>())) ?? []
        var byKey = Dictionary(uniqueKeysWithValues: existing.compactMap { poi -> (String, CachedPOI)? in
            poi.isPlaceholder ? nil : (key(poi.name, poi.latitude, poi.longitude), poi)
        })

        let now = Date()
        for r in results {
            let k = key(r.name, r.coordinate.latitude, r.coordinate.longitude)
            if let poi = byKey[k] {
                poi.distanceMiles = r.distanceMiles
                poi.cachedAt = now
                poi.locationLabel = r.locality
            } else {
                let poi = CachedPOI(name: r.name, category: r.category, typeLabel: r.typeLabel,
                                    distanceMiles: r.distanceMiles, phone: r.phone,
                                    locationLabel: r.locality, cachedAt: now, isPlaceholder: false,
                                    latitude: r.coordinate.latitude, longitude: r.coordinate.longitude)
                context.insert(poi)
                byKey[k] = poi
            }
        }

        evict(around: loc, now: now)
        try? context.save()

        lastRefreshLocation = loc
        lastUpdated = now
        userCoordinate = loc.coordinate
        recomputeCounts()
    }

    /// Sliding-window eviction: drop cached help that is well behind/away or stale,
    /// keeping a trailing buffer near the user. Bounds storage.
    private func evict(around loc: CLLocation, now: Date) {
        let all = (try? context.fetch(FetchDescriptor<CachedPOI>())) ?? []
        for poi in all where !poi.isPlaceholder {
            let d = loc.distance(from: CLLocation(latitude: poi.latitude, longitude: poi.longitude))
            if d > evictBehindMeters || now.timeIntervalSince(poi.cachedAt) > maxCacheAge {
                context.delete(poi)
            }
        }
    }

    private func removePlaceholders() {
        let placeholders = (try? context.fetch(FetchDescriptor<CachedPOI>()))?.filter { $0.isPlaceholder } ?? []
        placeholders.forEach { context.delete($0) }
    }

    private func recomputeCounts() {
        let all = (try? context.fetch(FetchDescriptor<CachedPOI>())) ?? []
        var c: [CachedPOI.Category: Int] = [:]
        for poi in all { c[poi.category, default: 0] += 1 }
        counts = c
        // Honest, record-size-based estimate (we don't store map tiles).
        cachedBytes = all.reduce(0) { $0 + $1.name.utf8.count + $1.typeLabel.utf8.count
                                        + $1.phone.utf8.count + $1.locationLabel.utf8.count + 96 }
    }

    private func key(_ name: String, _ lat: Double, _ lon: Double) -> String {
        "\(name)|\(String(format: "%.3f", lat))|\(String(format: "%.3f", lon))"
    }

    // MARK: Background refresh entry point (BGTaskScheduler)
    func backgroundRefresh() async {
        guard isEnabled else { return }
        await refreshNow()
    }
}
