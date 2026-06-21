import SwiftUI

/// Gradients from the handoff. CSS angles are mapped to SwiftUI unit points:
/// CSS 0deg = upward; angle increases clockwise. SwiftUI start/end are the
/// two ends of the gradient line.
enum GBGradient {

    /// Hero / welcome bg: linear-gradient(155deg, #3D6418 0%, #0C2312 38%, #031107 100%)
    static let hero = LinearGradient(
        stops: [
            .init(color: Color(hex: 0x3D6418), location: 0.0),
            .init(color: GBColor.bgSecondary,  location: 0.38),
            .init(color: GBColor.bgPrimary,    location: 1.0),
        ],
        startPoint: .topTrailing, endPoint: .bottomLeading
    )

    /// Primary button: linear-gradient(180deg, #8AD84E, #4CAF6A 55%, #2E7D4F)
    static let primaryButton = LinearGradient(
        stops: [
            .init(color: GBColor.lightEmerald, location: 0.0),
            .init(color: GBColor.brandGreen,   location: 0.55),
            .init(color: GBColor.darkUtility,  location: 1.0),
        ],
        startPoint: .top, endPoint: .bottom
    )

    /// Standard card fill: linear-gradient(180deg, #1B3A24, #102a18)
    static let card = LinearGradient(
        colors: [GBColor.cardTop, GBColor.cardBottom],
        startPoint: .top, endPoint: .bottom
    )

    /// Tile fill seen on Home action tiles: 180deg #1B3A24 -> #102a18 (same family).
    static let tile = card

    /// Travel activate bg: linear-gradient(160deg, #102a18, #031107 55%)
    static let travelActivate = LinearGradient(
        stops: [
            .init(color: GBColor.cardBottom, location: 0.0),
            .init(color: GBColor.bgPrimary,  location: 0.55),
        ],
        startPoint: .topTrailing, endPoint: .bottomLeading
    )

    /// Sync progress bar fill: linear-gradient(90deg, #4CAF6A, #A4D65E)
    static let progress = LinearGradient(
        colors: [GBColor.brandGreen, GBColor.statusLime],
        startPoint: .leading, endPoint: .trailing
    )

    /// Lime "ready / check" badge fill: 180deg #8AD84E -> #2E7D4F
    static let limeBadge = LinearGradient(
        colors: [GBColor.lightEmerald, GBColor.darkUtility],
        startPoint: .top, endPoint: .bottom
    )

    /// Rust hazard card fill (safety-block branch): rgba(193,80,46,.22) -> rgba(.1)
    static let hazardCard = LinearGradient(
        colors: [GBColor.warning.opacity(0.22), GBColor.warning.opacity(0.10)],
        startPoint: .top, endPoint: .bottom
    )
}
