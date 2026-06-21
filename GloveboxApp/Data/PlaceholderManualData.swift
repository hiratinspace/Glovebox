import Foundation
import SwiftData

// MARK: - Placeholder manual / issue content
//
// TODO(real data source): The spec calls for fetching real owner's-manual
// content + a make/model/year issue reference from a public source. No such
// source is wired up yet, so the chunks below are CLEARLY-LABELED PLACEHOLDER
// guidance (generic, conservative, not manufacturer-specific). They are stored
// with `isPlaceholder = true` and must never be presented to the user as
// authoritative manufacturer data. Specs are intentionally generic ("verify in
// your manual") rather than fabricated exact figures.

enum SyncSection: String, CaseIterable {
    case ownersManual   = "Owner's manual"
    case commonIssues   = "Common issues & fixes"
    case warningLights  = "Warning-light meanings"
    case fluids         = "Fluids & capacities"
    case torqueSpecs    = "Torque specs"
}

enum PlaceholderManualData {

    /// (section, title, text, safeForDIY)
    private static let entries: [(SyncSection, String, String, Bool)] = [
        // Owner's manual
        (.ownersManual, "Welcome & overview",
         "This is placeholder owner's-manual content cached for offline use. Always confirm procedures and specifications against your vehicle's actual printed manual before acting on anything safety-related.",
         true),
        (.ownersManual, "Dashboard tour",
         "Your instrument cluster shows speed, fuel/charge level, coolant temperature, and a row of warning indicators. A steady amber light generally means 'service soon'; a flashing or red light means stop and address it now.",
         true),

        // Common issues & fixes
        (.commonIssues, "Check engine light is on",
         "A check engine light most often means a loose fuel cap, an oxygen (O2) sensor, or the catalytic converter. Start simple: shut the engine off, re-seat the fuel cap until it clicks, and drive a short loop — it often clears within a drive cycle or two. If the light is FLASHING, stop driving and get it looked at.",
         true),
        (.commonIssues, "Car won't start",
         "If it cranks but won't fire, it's usually fuel or spark. If it just clicks, it's most likely a weak 12V battery or a loose terminal. Quick test: try the headlights — dim or dead points at the battery. A jump start is DIY-safe; follow the correct cable order (positive to dead, positive to good, negative to good, ground to engine block of dead car).",
         true),
        (.commonIssues, "Coolant temperature is high",
         "Treat a high coolant temperature as 'pull over soon.' Turn off the A/C, set the heater to max to draw heat off the engine, and find a safe spot to idle or shut down. Never open the radiator or coolant cap while hot. Once fully cool, check the reservoir level and top up if low.",
         true),
        (.commonIssues, "Tire looks low",
         "Check pressure with a gauge when tires are cold and inflate to the value on the driver's-door placard (a typical range is 32–36 psi — verify yours). A slow leak from a nail can often be handled with a plug/patch by a shop; a blowout or sidewall damage means replace, not repair.",
         true),

        // Warning-light meanings
        (.warningLights, "Oil pressure warning",
         "A red oil-can symbol means low oil pressure. Stop safely and shut off the engine as soon as you can — running with low oil pressure can cause serious engine damage. Check the oil level once cool; if it's adequate and the light stays on, do not keep driving.",
         true),
        (.warningLights, "Battery / charging light",
         "A red battery symbol means the charging system isn't keeping up (often the alternator or belt). You may have limited drive time on the battery alone. Reduce electrical load (A/C, heated seats) and head somewhere safe; have the charging system tested.",
         true),
        (.warningLights, "Brake system warning",
         "A red brake light can mean the parking brake is engaged, low brake fluid, or a hydraulic fault. If the pedal also feels soft or low, treat it as a serious safety issue and stop driving — brake hydraulic repairs are not a DIY job.",
         false),

        // Fluids & capacities
        (.fluids, "Engine oil",
         "Use the oil grade specified in your manual (commonly 0W-20 or 5W-30 on modern engines — verify yours). Check the level on level ground with the engine off and warm; the dipstick should read between the low and full marks.",
         true),
        (.fluids, "Engine coolant",
         "Use the coolant type your manufacturer specifies and don't mix incompatible types. Check the reservoir level only when the engine is cool. Capacities vary widely by engine — confirm the exact figure in your manual.",
         true),
        (.fluids, "Brake fluid",
         "Checking the LEVEL is fine to do yourself: the reservoir is usually on the driver's-side firewall; the fluid should sit between MIN and MAX. Use only the DOT rating specified on the cap. Low fluid can indicate worn pads or a leak — the actual repair is not DIY.",
         true),

        // Torque specs
        (.torqueSpecs, "Lug nuts (wheel)",
         "Wheel lug nuts must be torqued to spec in a star/criss-cross pattern — a typical passenger-car figure is around 80–100 lb-ft, but VERIFY the exact value for your vehicle. Under- or over-torquing is a safety risk. Re-check after ~50 miles following a wheel change.",
         true),
        (.torqueSpecs, "Drain plug & general note",
         "Fastener torque values matter for safety-critical parts. This placeholder set lists only general guidance; always use the manufacturer's exact torque figures and a calibrated torque wrench for any safety-related fastener.",
         true),
    ]

    /// Instantiate placeholder chunks for a single section and insert them.
    @discardableResult
    static func makeChunks(for vehicle: Vehicle, section: SyncSection,
                           in context: ModelContext) -> [ManualChunk] {
        let chunks = entries
            .filter { $0.0 == section }
            .map { (sec, title, text, diy) in
                ManualChunk(section: sec.rawValue, title: title, text: text,
                            safeForDIY: diy, isPlaceholder: true, vehicle: vehicle)
            }
        chunks.forEach { context.insert($0) }
        return chunks
    }

    /// Instantiate placeholder chunks bound to a vehicle and insert them.
    @discardableResult
    static func makeChunks(for vehicle: Vehicle, in context: ModelContext) -> [ManualChunk] {
        SyncSection.allCases.flatMap { makeChunks(for: vehicle, section: $0, in: context) }
    }

    /// Approximate cached size used for the "X MB cached" label. Real byte count
    /// once a true data source exists; for now, the chunk text size + a manual
    /// allowance, so the number isn't fabricated out of thin air.
    static func approximateCacheBytes(for chunks: [ManualChunk]) -> Int {
        let textBytes = chunks.reduce(0) { $0 + $1.text.utf8.count + $1.title.utf8.count }
        return textBytes + 4_200_000 // placeholder manual PDF allowance (~4 MB)
    }
}
