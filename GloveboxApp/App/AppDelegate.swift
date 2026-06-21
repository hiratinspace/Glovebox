import UIKit

/// BGTaskScheduler identifiers must be registered before launch completes.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        BGTaskManager.register()
        return true
    }
}
