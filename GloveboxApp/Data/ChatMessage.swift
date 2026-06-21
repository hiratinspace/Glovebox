import Foundation
import SwiftData

/// A diagnosis conversation message, persisted **per vehicle** (Phase 3 fleshes
/// out generation; the model is defined here so the SwiftData schema is stable).
@Model
final class ChatMessage {
    enum Role: String, Codable {
        case user, bot, block, fallback
    }

    @Attribute(.unique) var id: UUID
    var roleRaw: String
    var text: String
    var source: String?      // e.g. "From your cached owner's manual"
    var safeForDIY: Bool
    var blockedTopic: String? // for safety-block messages, e.g. "Brake"
    var createdAt: Date
    var vehicle: Vehicle?

    var role: Role { Role(rawValue: roleRaw) ?? .bot }

    init(role: Role,
         text: String,
         source: String? = nil,
         safeForDIY: Bool = false,
         blockedTopic: String? = nil,
         vehicle: Vehicle? = nil) {
        self.id = UUID()
        self.roleRaw = role.rawValue
        self.text = text
        self.source = source
        self.safeForDIY = safeForDIY
        self.blockedTopic = blockedTopic
        self.createdAt = Date()
        self.vehicle = vehicle
    }
}
