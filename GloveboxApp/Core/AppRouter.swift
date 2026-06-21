import SwiftUI
import Observation

/// Cross-cutting presentation state so the Help sheet and the always-reachable
/// Emergency screen can be opened from anywhere (Help pill, Home, the Phase 3
/// safety-block branch, Travel Mode), regardless of the selected tab.
@Observable
final class AppRouter {
    var helpPresented = false
    var emergencyPresented = false

    func openHelp() { helpPresented = true }
    func closeHelp() { helpPresented = false }

    func openEmergency() {
        helpPresented = false
        emergencyPresented = true
    }
    func closeEmergency() { emergencyPresented = false }
}
