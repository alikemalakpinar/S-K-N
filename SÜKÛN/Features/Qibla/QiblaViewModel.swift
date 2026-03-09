import Foundation
import CoreLocation
import SwiftUI

@Observable
final class QiblaViewModel: NSObject, CLLocationManagerDelegate {
    var heading: Double = 0
    var qiblaDirection: Double = 0
    var accuracy: Double = -1
    var isCalibrationNeeded = false
    var locationName: String = ""
    var hasLocation = false
    var errorMessage: String?

    // Kaaba coordinates (decimal degrees)
    private static let kaabaLatDeg = 21.4225
    private static let kaabaLonDeg = 39.8262
    private static let kaabaLatRad = kaabaLatDeg * .pi / 180
    private static let kaabaLonRad = kaabaLonDeg * .pi / 180

    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?

    /// The angle the user needs to rotate: positive = turn right, negative = turn left
    var rotationAngle: Double {
        var diff = qiblaDirection - heading
        if diff < -180 { diff += 360 }
        if diff > 180 { diff -= 360 }
        return diff
    }

    /// Compass rotation for the UI (rotate opposite to heading)
    var compassRotation: Double {
        -heading
    }

    /// Whether the device is pointing close to the Qibla (within 5 degrees)
    var isPointingAtQibla: Bool {
        abs(rotationAngle) < 5
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1
    }

    func start() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        } else {
            errorMessage = "Bu cihazda pusula kullanılamıyor."
        }
    }

    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            if newHeading.headingAccuracy < 0 {
                isCalibrationNeeded = true
                return
            }
            isCalibrationNeeded = false
            // Prefer true heading if available, fall back to magnetic
            heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
            accuracy = newHeading.headingAccuracy
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            currentCoordinate = location.coordinate
            hasLocation = true
            calculateQiblaDirection()
            reverseGeocode(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let clError = error as? CLError, clError.code == .denied {
                errorMessage = "Konum erişimi reddedildi. Ayarlar'dan konum iznini etkinleştirin."
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.startUpdatingLocation()
                if CLLocationManager.headingAvailable() {
                    manager.startUpdatingHeading()
                }
            }
        }
    }

    // MARK: - Qibla Calculation

    /// Great circle bearing from current position to Kaaba
    private func calculateQiblaDirection() {
        guard let coord = currentCoordinate else { return }

        let lat = coord.latitude * .pi / 180
        let lon = coord.longitude * .pi / 180

        let dLon = Self.kaabaLonRad - lon

        let y = sin(dLon)
        let x = cos(lat) * tan(Self.kaabaLatRad) - sin(lat) * cos(dLon)
        var angle = atan2(y, x) * 180 / .pi

        // Normalize to 0-360
        if angle < 0 { angle += 360 }

        qiblaDirection = angle
    }

    // MARK: - Reverse Geocoding

    private var lastGeocodedLocation: CLLocation?

    private func reverseGeocode(_ location: CLLocation) {
        // Only re-geocode if moved significantly (500m+)
        if let last = lastGeocodedLocation,
           location.distance(from: last) < 500 {
            return
        }
        lastGeocodedLocation = location

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self, let placemark = placemarks?.first else { return }
            Task { @MainActor in
                let city = placemark.locality ?? placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""
                if !city.isEmpty && !country.isEmpty {
                    self.locationName = "\(city), \(country)"
                } else if !country.isEmpty {
                    self.locationName = country
                }
            }
        }
    }
}
