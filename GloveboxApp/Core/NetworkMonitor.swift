import Foundation
import Network
import Observation

/// Real connectivity signal from `NWPathMonitor`. Drives offline banners, sync
/// availability, and emergency-from-cache. Replaces the prototype's demo toggle.
@Observable
final class NetworkMonitor {
    private(set) var isOnline: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.glovebox.networkmonitor")

    init() {
        #if DEBUG
        // Dev-only seam for verifying the offline UI on a simulator that is
        // always online. Not a shipped affordance.
        if ProcessInfo.processInfo.environment["GB_FORCE_OFFLINE"] == "1" {
            isOnline = false
            return
        }
        #endif
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            DispatchQueue.main.async { self?.isOnline = online }
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
