import Foundation
import CoreLocation

protocol LocationServiceProtocol: Sendable {
    func requestPermission() async
    func currentCoordinates() async throws -> CLLocationCoordinate2D
}

final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate, @unchecked Sendable {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private var permissionContinuation: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestPermission() async {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            await withCheckedContinuation { continuation in
                self.permissionContinuation = continuation
                self.manager.requestWhenInUseAuthorization()
            }
        }
    }

    func currentCoordinates() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw LocationError.notAuthorized
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.manager.requestLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .notDetermined {
            permissionContinuation?.resume()
            permissionContinuation = nil
        }
    }
}

enum LocationError: LocalizedError {
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Konum erişimi sağlanamadı. Lütfen Ayarlar'dan konum iznini etkinleştirin."
        }
    }
}
