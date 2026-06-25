import Foundation

/// Code-enforced safety classifier. Runs on **every** request (input) and
/// **every** generated response (output) to detect safety-critical systems:
/// brakes (beyond fluid-level check), airbags/SRS, high-voltage EV/hybrid battery,
/// fuel-system repairs (beyond cap/line inspection), and structural/frame work.
///
/// Product decision: Glovebox is for drivers who may be stranded with NO mechanic
/// and NO signal, so it does **not** withhold guidance. Instead, a hit surfaces a
/// prominent "safety-critical — proceed at your own risk" caution attached to the
/// answer. Detection runs on the model OUTPUT too, so the caution is attached even
/// if the topic only emerges in the generated steps.
enum SafetyFilter {

    enum Verdict: Equatable {
        case allow
        case caution(topic: String)
    }

    /// A disallowed safety-critical system and the patterns that identify it.
    private struct Topic {
        let name: String
        let isHit: (String) -> Bool
    }

    private static let topics: [Topic] = [
        Topic(name: "Airbag / SRS") { s in
            matches(s, #"air\s?bag|\bsrs\b|pretensioner|seat\s?belt tensioner|clockspring"#)
        },
        Topic(name: "Structural / frame") { s in
            matches(s, #"\bframe\b|structural|chassis|unibody|sub\s?frame|crumple|frame rail|weld(ing)? (the )?(frame|body)"#)
        },
        Topic(name: "High-voltage battery") { s in
            // High-voltage / traction systems only — a 12V battery jump start is DIY-safe.
            matches(s, #"high.?voltage|traction battery|\bhv battery\b|orange cable|[48]00\s?v"#)
            || (matches(s, #"battery|cell|pack|inverter"#) && matches(s, #"\bev\b|hybrid|electric vehicle|lithium drive|drive battery"#))
        },
        Topic(name: "Fuel system") { s in
            // Repairs beyond cap/line inspection. Allow generic "fuel or spark" talk
            // and the fuel cap.
            matches(s, #"fuel"#)
            && matches(s, #"pump|injector|\brail\b|pressure regulat|fuel tank|fuel line repair|fuel leak|fuel filter|fuel system (repair|service)|replace .*fuel"#)
            && !matches(s, #"fuel cap"#)
        },
        Topic(name: "Brake") { s in
            // Beyond a fluid-level check. Strong brake-component terms block on their
            // own (so dropping the word "brake" can't bypass it); generic verbs near
            // "brake" also block. A fluid-level/light check stays allowed.
            matches(s, #"\bcaliper|\brotor|brake pad|\bbrake bleed|bleed (the )?brake|master cylinder|brake line|brake hose|brake job|brake disc|brake drum|brake shoe"#)
            || (matches(s, #"brake"#)
                && matches(s, #"replace|repair|change|fix|install|remove|swap|bleed|disc|drum|shoe|grind"#))
        },
    ]

    /// Classify free-text user input for a safety-critical topic.
    static func classifyInput(_ text: String) -> Verdict { classify(text) }

    /// Classify model output — attaches the caution if the steps touch a critical system.
    static func classifyOutput(_ text: String) -> Verdict { classify(text) }

    private static func classify(_ text: String) -> Verdict {
        let s = text.lowercased()
        for topic in topics where topic.isHit(s) {
            return .caution(topic: topic.name)
        }
        return .allow
    }

    private static func matches(_ s: String, _ pattern: String) -> Bool {
        s.range(of: pattern, options: [.regularExpression]) != nil
    }
}
