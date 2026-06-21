import SwiftUI

/// Spacing scale: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64
enum GBSpace {
    static let xxs: CGFloat = 4
    static let xs:  CGFloat = 8
    static let sm:  CGFloat = 12
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

/// Corner radii: small 12–14, medium 16–18, large 20–22, app icon 28.
enum GBRadius {
    static let input:  CGFloat = 14   // form fields
    static let small:  CGFloat = 13
    static let button: CGFloat = 16
    static let card:   CGFloat = 18
    static let large:  CGFloat = 20
    static let xLarge: CGFloat = 22
    static let icon:   CGFloat = 28   // app icon / hero glyph
    static let pill:   CGFloat = 24
}

enum GBMetrics {
    static let minTouch: CGFloat = 44
}
