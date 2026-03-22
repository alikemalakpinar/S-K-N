import CoreHaptics
import Foundation

public final class TasbihHapticsManager {
    public static let shared = TasbihHapticsManager()
    
    private var engine: CHHapticEngine?
    private var isSupported: Bool = false
    
    private init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        isSupported = true
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Reset handler
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
        } catch {
            print("Haptic Engine Error: \(error)")
        }
    }
    
    /// Play a synchronous haptic + audio tap, scaling intensity by the normalized velocity (0.0 to 1.0)
    public func playCollisionFeedback(intensity: Float, isWall: Bool = false) {
        guard isSupported, let engine = engine else { return }
        
        // Clamp and map intensity
        let clampedIntensity = max(0.2, min(intensity, 1.0))
        let sharpness = isWall ? Float(0.8) : Float(0.5)
        
        // Create haptic event
        let hapticIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: clampedIntensity)
        let hapticSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let hapticEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [hapticIntensity, hapticSharpness], relativeTime: 0)
        
        // Create synthetic audio event to match realistic bead collision
        let audioVolume = CHHapticEventParameter(parameterID: .audioVolume, value: clampedIntensity)
        let audioPitch = CHHapticEventParameter(parameterID: .audioPitch, value: isWall ? -0.2 : 0.0)
        let audioEvent = CHHapticEvent(eventType: .audioClick, parameters: [audioVolume, audioPitch], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [hapticEvent, audioEvent], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
}
