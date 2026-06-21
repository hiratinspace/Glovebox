import SwiftUI

/// Public Sans (bundled). Falls back to system if registration fails.
/// Weights: 400/500/600/700/800. Style reference: highway signage, vehicle manuals.
enum GBFont {
    static func regular(_ size: CGFloat) -> Font  { .custom("PublicSans-Regular",  size: size) }
    static func medium(_ size: CGFloat) -> Font   { .custom("PublicSans-Medium",   size: size) }
    static func semibold(_ size: CGFloat) -> Font { .custom("PublicSans-SemiBold", size: size) }
    static func bold(_ size: CGFloat) -> Font     { .custom("PublicSans-Bold",     size: size) }
    static func extrabold(_ size: CGFloat) -> Font{ .custom("PublicSans-ExtraBold",size: size) }
}

/// Semantic text styles from the handoff typography scale. Each carries the
/// correct font, tracking (letter-spacing) and color so call sites stay terse.
enum GBTextStyle {
    case display          // 28/800, -0.02em  (page hero, e.g. "Glovebox")
    case wordmark         // 30/800, -0.02em  (welcome wordmark)
    case pageTitle        // 27/800, -0.02em
    case sectionTitle     // 20/700
    case cardTitle        // 17/700
    case body             // 15/400
    case bodySmall        // 13/400
    case label            // 11/600, 0.12em, UPPERCASE
    case buttonPrimary    // 16/700
    case buttonSecondary  // 16/600

    var font: Font {
        switch self {
        case .display:         return GBFont.extrabold(28)
        case .wordmark:        return GBFont.extrabold(30)
        case .pageTitle:       return GBFont.extrabold(27)
        case .sectionTitle:    return GBFont.bold(20)
        case .cardTitle:       return GBFont.bold(17)
        case .body:            return GBFont.regular(15)
        case .bodySmall:       return GBFont.regular(13)
        case .label:           return GBFont.semibold(11)
        case .buttonPrimary:   return GBFont.bold(16)
        case .buttonSecondary: return GBFont.semibold(16)
        }
    }

    var tracking: CGFloat {
        switch self {
        case .display:   return -0.56   // -0.02em * 28
        case .wordmark:  return -0.60   // -0.02em * 30
        case .pageTitle: return -0.54   // -0.02em * 27
        case .label:     return 1.32    //  0.12em * 11
        default:         return 0
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .body:      return 6   // ~1.5 line-height at 15pt
        case .bodySmall: return 4
        default:         return 0
        }
    }

    var isUppercased: Bool { self == .label }
}

/// View-level styling: font + tracking + color + line spacing + (for labels)
/// uppercasing, in one modifier. Works on `Text` and any other view.
struct GBTextModifier: ViewModifier {
    let style: GBTextStyle
    let color: Color
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
            .foregroundColor(color)
            .lineSpacing(style.lineSpacing)
            .textCase(style.isUppercased ? .uppercase : nil)
    }
}

extension View {
    func gbText(_ style: GBTextStyle, color: Color = GBColor.textPrimary) -> some View {
        modifier(GBTextModifier(style: style, color: color))
    }
}
