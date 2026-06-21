import Foundation

enum RelativeTime {
    /// Compact "synced" phrasing: "just now", "2 min ago", "3 hr ago", "2 days ago".
    static func short(_ date: Date, now: Date = Date()) -> String {
        let seconds = max(0, now.timeIntervalSince(date))
        switch seconds {
        case ..<90:            return "just now"
        case ..<3600:          return "\(Int(seconds / 60)) min ago"
        case ..<86_400:        return "\(Int(seconds / 3600)) hr ago"
        default:               return "\(Int(seconds / 86_400)) days ago"
        }
    }
}
