import Foundation
import CoreLocation
import CoreMotion
import SwiftUI
import Combine

/// A heavy-duty, state-of-the-art CoreLocation and CoreMotion engine
/// Calculates True North, Magnetic North, Gyroscopic Tilt, and Qibla heading.
public final class QiblaEngineService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published Real-Time Metrics
    @Published public private(set) var currentHeading: Double = 0
    @Published public private(set) var trueHeading: Double = 0
    @Published public private(set) var qiblaHeading: Double = 0
    @Published public private(set) var angleToQibla: Double = 0
    @Published public private(set) var isAccuracyOptimized: Bool = false
    @Published public private(set) var pitch: Double = 0
    @Published public private(set) var roll: Double = 0
    @Published public private(set) var location: CLLocationCoordinate2D?
    @Published public private(set) var errorStatus: String? = nil
    
    // Core Services
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    
    // Kaaba Coordinates (Makkah)
    private let kaabaLatitude: Double = 21.422487
    private let kaabaLongitude: Double = 39.826206
    
    // Low-Pass Filter State (for ultra-smooth needle rendering)
    private var filteredHeading: Double = 0
    private let filterFactor: Double = 0.2
    
    // Haptic State
    private var lastHapticAngle: Double?
    private var isQiblaLockedState: Bool = false
    
    // MARK: - Lifecycle
    
    public override init() {
        super.init()
        setupLocationManager()
        setupMotionManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5.0 // Meters
        locationManager.headingFilter = 0.5 // Degrees
        
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        } else {
            errorStatus = "Cihaz pusula sensörünü desteklemiyor."
        }
    }
    
    private func setupMotionManager() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] motion, error in
                guard let self = self, let motion = motion else { return }
                
                // Advanced 3D attitude tracking for visual parallax
                self.pitch = motion.attitude.pitch
                self.roll = motion.attitude.roll
            }
        }
    }
    
    public func requestPermissions() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location.coordinate
        
        // Mathematical Great Circle Formula for exact Qibla heading
        self.qiblaHeading = calculateQibla(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        updateAngles()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 {
            self.errorStatus = "Pusula doğruluğu çok düşük. Lütfen cihazınızı kalibre edin (8 çizin)."
            self.isAccuracyOptimized = false
            return
        }
        
        self.errorStatus = nil
        self.isAccuracyOptimized = newHeading.headingAccuracy <= 15.0
        
        // Apply Low-Pass Filter for smooth visual tracking
        let rawHeading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        
        // Prevent wrapping glitches (359 -> 1 degree snapping)
        let diff = rawHeading - self.filteredHeading
        if diff > 180 {
            self.filteredHeading += 360
        } else if diff < -180 {
            self.filteredHeading -= 360
        }
        
        self.filteredHeading = (rawHeading * filterFactor) + (self.filteredHeading * (1.0 - filterFactor))
        
        // Normalize
        if self.filteredHeading >= 360 { self.filteredHeading -= 360 }
        if self.filteredHeading < 0 { self.filteredHeading += 360 }
        
        self.trueHeading = newHeading.trueHeading
        self.currentHeading = self.filteredHeading
        
        updateAngles()
    }
    
    // MARK: - Mathematical Core
    
    /// Haversine / Great Circle algorithm implementation
    private func calculateQibla(latitude: Double, longitude: Double) -> Double {
        let phiK = kaabaLatitude * .pi / 180.0
        let lambdaK = kaabaLongitude * .pi / 180.0
        let phi = latitude * .pi / 180.0
        let lambda = longitude * .pi / 180.0
        
        let y = sin(lambdaK - lambda)
        let x = cos(phi) * tan(phiK) - sin(phi) * cos(lambdaK - lambda)
        
        var qibla = atan2(y, x) * 180.0 / .pi
        if qibla < 0 {
            qibla += 360.0
        }
        return qibla
    }
    
    private func updateAngles() {
        var angle = qiblaHeading - currentHeading
        if angle < 0 {
            angle += 360
        }
        self.angleToQibla = angle
        
        // Haptic Feedback Integration
        let shortestAngleToQibla = min(angle, 360 - angle)
        
        if isAccuracyOptimized {
            if shortestAngleToQibla <= 2.0 {
                // Fully Locked
                if !isQiblaLockedState {
                    isQiblaLockedState = true
                    DS.Haptic.qiblaLocked()
                }
            } else {
                isQiblaLockedState = false
                
                // Heartbeat as it gets closer (within 15 degrees)
                if shortestAngleToQibla <= 15.0 {
                    // Tap every 2 degrees of change
                    let currentHapticAngle = round(shortestAngleToQibla / 2.0)
                    if lastHapticAngle != currentHapticAngle {
                        DS.Haptic.dhikrTap() // Very light, like a heartbeat
                        lastHapticAngle = currentHapticAngle
                    }
                } else {
                    lastHapticAngle = nil
                }
            }
        }
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        motionManager.stopDeviceMotionUpdates()
    }
}
