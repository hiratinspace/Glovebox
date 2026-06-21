import Foundation
import CoreLocation

/// CoreLocation wrapper tuned for **battery-friendly, distance-based** updates —
/// not continuous high-accuracy GPS. Foreground: standard updates with a coarse
/// accuracy and a large distance filter (~every half-mile). Background: significant
/// location changes. Reports changes via closures (owned by TravelService).
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var onAuthChange: ((CLAuthorizationStatus) -> Void)?
    var onLocation: ((CLLocation) -> Void)?

    var authorizationStatus: CLAuthorizationStatus { manager.authorizationStatus }
    private(set) var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 800            // ~0.5 mi between updates
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .automotiveNavigation
    }

    /// Step the permission ladder: When-In-Use first, then upgrade to Always.
    func requestAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:        manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:  manager.requestAlwaysAuthorization()
        default:                    break
        }
    }

    func start() {
        let status = manager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }
        // Background updates require Always + the location background mode.
        manager.allowsBackgroundLocationUpdates = (status == .authorizedAlways)
        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        if let loc = manager.location { lastLocation = loc; onLocation?(loc) }
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.stopMonitoringSignificantLocationChanges()
        manager.allowsBackgroundLocationUpdates = false
    }

    /// One-shot current location request (used by background refresh).
    func requestOneShot() { manager.requestLocation() }

    // MARK: CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        onAuthChange?(status)
        if status == .authorizedWhenInUse {
            // Try to upgrade so background caching can work.
            manager.requestAlwaysAuthorization()
        }
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            start()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        lastLocation = loc
        onLocation?(loc)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Non-fatal: keep the last cached location and existing cache.
    }
}
