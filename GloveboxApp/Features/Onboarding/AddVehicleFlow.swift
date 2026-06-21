import SwiftUI

/// Reusable add-a-vehicle mini-flow (Add Vehicle → Sync), used both at first run
/// and from the Garage "Add a vehicle" action.
struct AddVehicleFlow: View {
    var onFinish: () -> Void

    private enum Stage { case add, sync }
    @State private var stage: Stage = .add
    @State private var created: Vehicle?

    var body: some View {
        ZStack {
            GBColor.bgPrimary.ignoresSafeArea()
            switch stage {
            case .add:
                AddVehicleView(
                    onSaved: { vehicle in created = vehicle; stage = .sync },
                    onBack: onFinish)
            case .sync:
                if let created {
                    SyncView(vehicle: created, onEnter: onFinish, enterTitle: "Done")
                }
            }
        }
    }
}
