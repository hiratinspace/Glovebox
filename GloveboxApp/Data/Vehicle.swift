import Foundation
import SwiftData

/// A user's vehicle. Stored locally via SwiftData (Core Data under the hood) —
/// vehicle data stays on the phone by default, per the privacy spec.
@Model
final class Vehicle {
    @Attribute(.unique) var id: UUID
    var year: String
    var make: String
    var model: String
    var trim: String
    var createdAt: Date

    /// Exactly one vehicle is active at a time (see `VehicleStore.setActive`).
    var isActive: Bool

    /// Offline-cache state.
    var ready: Bool          // manual + issue data cached for offline use
    var syncedAt: Date?      // nil = never synced
    var cacheBytes: Int      // size of cached resources

    @Relationship(deleteRule: .cascade, inverse: \ManualChunk.vehicle)
    var manualChunks: [ManualChunk] = []

    @Relationship(deleteRule: .cascade, inverse: \ChatMessage.vehicle)
    var messages: [ChatMessage] = []

    init(year: String, make: String, model: String, trim: String) {
        self.id = UUID()
        self.year = year
        self.make = make
        self.model = model
        self.trim = trim
        self.createdAt = Date()
        self.isActive = false
        self.ready = false
        self.syncedAt = nil
        self.cacheBytes = 0
    }

    var displayName: String { "\(year) \(make) \(model)" }

    var cacheSizeMB: Double { Double(cacheBytes) / 1_048_576.0 }
}
