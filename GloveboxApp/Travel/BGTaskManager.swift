import Foundation
import BackgroundTasks

/// Registers and schedules background cache refreshes via `BGTaskScheduler`.
/// Registration must happen at launch (in the app delegate); the actual work
/// closure is supplied once `TravelService` exists.
enum BGTaskManager {
    static let refreshID = "com.glovebox.app.travelcache.refresh"
    static let processID = "com.glovebox.app.travelcache.process"

    /// Set by the app once TravelService is available.
    static var onRefresh: (() async -> Void)?

    /// Must be called during `application(_:didFinishLaunchingWithOptions:)`.
    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshID, using: nil) { task in
            handle(task)
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: processID, using: nil) { task in
            handle(task)
        }
    }

    /// Schedule the next background refresh + a heavier processing pass. Call when
    /// entering the background.
    static func schedule() {
        let refresh = BGAppRefreshTaskRequest(identifier: refreshID)
        refresh.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(refresh)

        let process = BGProcessingTaskRequest(identifier: processID)
        process.requiresNetworkConnectivity = true
        process.requiresExternalPower = false
        process.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        try? BGTaskScheduler.shared.submit(process)
    }

    private static func handle(_ task: BGTask) {
        schedule() // always queue the next one
        let work = Task {
            await onRefresh?()
            task.setTaskCompleted(success: true)
        }
        task.expirationHandler = {
            work.cancel()
            task.setTaskCompleted(success: false)
        }
    }
}
