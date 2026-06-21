import SwiftUI

/// Glovebox color tokens — values transcribed directly from the design handoff.
/// Overall feel target: ~70% deep forest green, ~20% utility emerald,
/// ~8% manual-paper cream, ~2% hazard lime.
enum GBColor {
    // MARK: Surfaces / backgrounds
    static let bgPrimary       = Color(hex: 0x031107) // App background
    static let bgSecondary     = Color(hex: 0x0C2312) // Inputs, recessed wells
    static let surface         = Color(hex: 0x14311C) // Raised surfaces
    static let cardTop         = Color(hex: 0x1B3A24) // Card gradient top
    static let cardBottom      = Color(hex: 0x102A18) // Card gradient bottom

    // MARK: Brand greens
    static let brandGreen      = Color(hex: 0x4CAF6A) // Primary brand
    static let darkUtility     = Color(hex: 0x2E7D4F) // Gradient base
    static let lightEmerald    = Color(hex: 0x8AD84E) // Gradient top / accents
    static let statusLime      = Color(hex: 0xA4D65E) // Status, highlights, key numbers, active tab

    // MARK: Text (warm cream)
    static let textPrimary     = Color(hex: 0xF2EFE6)
    static let textSecondary   = Color(hex: 0xF2EFE6, opacity: 0.72)
    static let textMuted       = Color(hex: 0xF2EFE6, opacity: 0.48)

    /// Cream at an arbitrary opacity — the design uses many rgba(242,239,230,a) values.
    static func cream(_ opacity: Double) -> Color { Color(hex: 0xF2EFE6, opacity: opacity) }

    // MARK: Hazard — RESERVED for genuine emergencies & the safety-block branch ONLY.
    static let warning         = Color(hex: 0xC1502E) // rust
    static let alertText       = Color(hex: 0xE0926E) // warning text on dark
    static let alertTextAlt    = Color(hex: 0xE08A5E)

    // MARK: Tab bar
    static let tabInactive     = Color(hex: 0x6E8A76)

    // MARK: Misc accents seen in the prototype
    static let userBubble      = Color(hex: 0x27502F)
    static let onPrimary       = Color(hex: 0x031107) // text on primary button
    static let onLime          = Color(hex: 0x08240F) // text on lime badges
}

extension Color {
    /// Hex initializer, e.g. `Color(hex: 0x4CAF6A)`.
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
