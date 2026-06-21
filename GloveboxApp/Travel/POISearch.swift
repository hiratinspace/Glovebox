import Foundation
import MapKit

/// A roadside-help result fetched from `MKLocalSearch`, ready to be cached.
struct POIResult {
    let name: String
    let category: CachedPOI.Category
    let typeLabel: String
    let phone: String
    let coordinate: CLLocationCoordinate2D
    let distanceMiles: Double
    let locality: String
}

/// Runs `MKLocalSearch` for each roadside-help category around a center point.
/// Online-only (requires network); callers fall back to the existing cache when
/// offline.
enum POISearch {
    /// (naturalLanguageQuery, category, typeLabel)
    private static let queries: [(String, CachedPOI.Category, String)] = [
        ("auto repair",         .mechanic, "AUTO SHOP"),
        ("towing service",      .towing,   "TOWING"),
        ("hospital urgent care",.hospital, "URGENT CARE"),
        ("gas station",         .fuel,     "GAS"),
        ("ev charging station", .fuel,     "EV CHARGING"),
        ("police station",      .police,   "NON-EMERGENCY"),
    ]

    static func search(around center: CLLocationCoordinate2D,
                       radiusMeters: CLLocationDistance = 32_000,
                       perCategory: Int = 4) async -> [POIResult] {
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: radiusMeters,
                                        longitudinalMeters: radiusMeters)
        let origin = CLLocation(latitude: center.latitude, longitude: center.longitude)

        var results: [POIResult] = []
        for (query, category, label) in queries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region
            if #available(iOS 13.0, *) { request.resultTypes = [.pointOfInterest] }

            let items = await run(MKLocalSearch(request: request))
            for item in items.prefix(perCategory) {
                let coord = item.placemark.coordinate
                let dist = origin.distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
                results.append(POIResult(
                    name: item.name ?? query.capitalized,
                    category: category,
                    typeLabel: label,
                    phone: sanitize(item.phoneNumber),
                    coordinate: coord,
                    distanceMiles: dist / 1609.344,
                    locality: item.placemark.locality ?? item.placemark.subLocality
                              ?? item.placemark.thoroughfare ?? "nearby"))
            }
        }
        return results
    }

    private static func run(_ search: MKLocalSearch) async -> [MKMapItem] {
        await withCheckedContinuation { continuation in
            search.start { response, _ in
                continuation.resume(returning: response?.mapItems ?? [])
            }
        }
    }

    private static func sanitize(_ phone: String?) -> String {
        guard let phone else { return "" }
        return phone.filter { $0.isNumber || $0 == "+" }
    }
}
