import Foundation
import SwiftData

// MARK: - Placeholder cached roadside-help POIs
//
// TODO(Phase 4 / real data): Travel Mode will populate the POI cache from
// `MKLocalSearch` along the route corridor (with sliding-window eviction). Until
// then these clearly-labeled placeholders make the Emergency screen real and
// genuinely backed by the on-device cache. They are stored with
// `isPlaceholder = true`; staleness timestamps below are real (relative to now).

enum PlaceholderPOIData {
    /// (name, category, typeLabel, miles, phone, location, minutesAgo)
    private static let entries: [(String, CachedPOI.Category, String, Double, String, String, Int)] = [
        ("Highway 6 Towing & Recovery", .towing,   "24/7 TOWING",    2.1, "+19705550142", "Exit 42", 6),
        ("Pine Ridge Auto Repair",      .mechanic, "AUTO SHOP",      3.4, "+19705550178", "Exit 42", 6),
        ("St. Mary's Urgent Care",      .hospital, "URGENT CARE",    5.0, "+19705550190", "Granby",  12),
        ("Summit Gas & Charge",         .fuel,     "GAS · EV (CCS)", 5.8, "+19705550110", "Granby",  12),
        ("Grand County Sheriff",        .police,   "NON-EMERGENCY",  12.0, "+19705550100", "",       18),
    ]

    static func seedIfEmpty(in context: ModelContext, now: Date = Date()) {
        let existing = (try? context.fetch(FetchDescriptor<CachedPOI>()))?.isEmpty ?? true
        guard existing else { return }
        for (name, cat, type, miles, phone, loc, minsAgo) in entries {
            let poi = CachedPOI(
                name: name, category: cat, typeLabel: type, distanceMiles: miles,
                phone: phone, locationLabel: loc,
                cachedAt: now.addingTimeInterval(TimeInterval(-minsAgo * 60)))
            context.insert(poi)
        }
        try? context.save()
    }
}
