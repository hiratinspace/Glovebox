import Foundation
import SwiftData

/// A roadside-help point of interest cached for offline use. In Phase 4 these are
/// populated by Travel Mode's sliding-window `MKLocalSearch` cache; for now they
/// are clearly-labeled placeholders (`isPlaceholder = true`) so the always-
/// reachable Emergency screen is real and reads from this cache.
@Model
final class CachedPOI {
    enum Category: String, Codable, CaseIterable {
        case towing, mechanic, hospital, fuel, police

        var symbol: String {
            switch self {
            case .towing:   return "box.truck.fill"
            case .mechanic: return "wrench.and.screwdriver.fill"
            case .hospital: return "cross.fill"
            case .fuel:     return "fuelpump.fill"
            case .police:   return "shield.fill"
            }
        }
    }

    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var typeLabel: String        // e.g. "24/7 TOWING", "AUTO SHOP", "GAS · EV (CCS)"
    var distanceMiles: Double
    var phone: String
    var locationLabel: String    // e.g. "Exit 42", "Granby"
    var cachedAt: Date
    var isPlaceholder: Bool
    // Coordinates of the POI (real MKLocalSearch results); 0/0 for placeholders.
    var latitude: Double
    var longitude: Double

    init(name: String, category: Category, typeLabel: String, distanceMiles: Double,
         phone: String, locationLabel: String, cachedAt: Date, isPlaceholder: Bool = true,
         latitude: Double = 0, longitude: Double = 0) {
        self.id = UUID()
        self.name = name
        self.categoryRaw = category.rawValue
        self.typeLabel = typeLabel
        self.distanceMiles = distanceMiles
        self.phone = phone
        self.locationLabel = locationLabel
        self.cachedAt = cachedAt
        self.isPlaceholder = isPlaceholder
        self.latitude = latitude
        self.longitude = longitude
    }

    var category: Category { Category(rawValue: categoryRaw) ?? .mechanic }

    var distanceLabel: String {
        distanceMiles < 10
            ? String(format: "%.1f mi", distanceMiles)
            : String(format: "%.0f mi", distanceMiles)
    }

    /// "cached 6 min ago · Exit 42". Never let stale data look fresh.
    func stalenessLabel(now: Date = Date()) -> String {
        let mins = Int(max(0, now.timeIntervalSince(cachedAt)) / 60)
        let when = mins < 1 ? "just now" : "\(mins) min ago"
        return locationLabel.isEmpty ? "cached \(when)" : "cached \(when) · \(locationLabel)"
    }

    /// Amber-flag stale entries (older than 15 min), per the design.
    func isStale(now: Date = Date()) -> Bool {
        now.timeIntervalSince(cachedAt) > 15 * 60
    }

    var telURL: URL? { URL(string: "tel:\(phone)") }
    var smsURL: URL? { URL(string: "sms:\(phone)") }
}
