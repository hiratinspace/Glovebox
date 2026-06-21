import Foundation
import SwiftData

/// A unit of cached manual / issue-reference text for a vehicle. These are what
/// the local vector index retrieves over (RAG) in Phase 3. Stored on-device.
@Model
final class ManualChunk {
    @Attribute(.unique) var id: UUID

    /// One of the cached sections shown on the Sync screen, e.g.
    /// "Owner's manual", "Common issues & fixes", "Warning-light meanings",
    /// "Fluids & capacities", "Torque specs".
    var section: String
    var title: String
    var text: String

    /// Each issue is tagged safe-for-DIY or not, per the spec.
    var safeForDIY: Bool

    /// TRUE while we have no real manual data source wired up. Surfaced so we
    /// never silently present placeholder data as real manufacturer content.
    var isPlaceholder: Bool

    var vehicle: Vehicle?

    init(section: String,
         title: String,
         text: String,
         safeForDIY: Bool,
         isPlaceholder: Bool = true,
         vehicle: Vehicle? = nil) {
        self.id = UUID()
        self.section = section
        self.title = title
        self.text = text
        self.safeForDIY = safeForDIY
        self.isPlaceholder = isPlaceholder
        self.vehicle = vehicle
    }
}
