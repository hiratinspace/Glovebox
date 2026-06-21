import Foundation
import SwiftData

/// Helpers for vehicle persistence + the single-active-vehicle invariant.
enum VehicleStore {

    static func activeVehicle(in context: ModelContext) -> Vehicle? {
        let descriptor = FetchDescriptor<Vehicle>(predicate: #Predicate { $0.isActive })
        return (try? context.fetch(descriptor))?.first
    }

    static func allVehicles(in context: ModelContext) -> [Vehicle] {
        let descriptor = FetchDescriptor<Vehicle>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Create a vehicle, insert it, and make it the active one.
    @discardableResult
    static func add(year: String, make: String, model: String, trim: String,
                    in context: ModelContext) -> Vehicle {
        let vehicle = Vehicle(year: year, make: make, model: model, trim: trim)
        context.insert(vehicle)
        setActive(vehicle, in: context)
        return vehicle
    }

    /// Make `vehicle` the sole active vehicle.
    static func setActive(_ vehicle: Vehicle, in context: ModelContext) {
        for other in allVehicles(in: context) where other.isActive && other.id != vehicle.id {
            other.isActive = false
        }
        vehicle.isActive = true
        try? context.save()
    }
}
