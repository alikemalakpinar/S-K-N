import Foundation
import CoreGraphics
import SwiftUI
import Combine

/// A custom 2D Rigid Body Physics Engine written exclusively for the Dhikr screen.
/// Simulates gravity, floor collisions, bead-to-bead collisions, restitution (bounciness).
public final class TasbihPhysicsEngine: ObservableObject {
    
    // MARK: - Physics Structures
    
    public struct Bead: Identifiable {
        public let id = UUID()
        public var position: CGPoint
        public var velocity: CGVector
        public var radius: CGFloat
        public var mass: CGFloat
        public var restitution: CGFloat // Bounciness
        public var colorIndex: Int
        public var stopped: Bool = false
    }
    
    @Published public private(set) var beads: [Bead] = []
    
    // Configuration
    private let gravity: CGFloat = 800.0   // Pixels/sec^2
    private let friction: CGFloat = 0.98
    private let floorY: CGFloat
    private let screenWidth: CGFloat
    
    private var lastUpdate: TimeInterval = 0
    private var displayLink: CADisplayLink?
    
    // Total count for Dhikr logic
    @Published public var totalDhikrCount: Int = 0
    
    // MARK: - Initialization
    
    public init(screenWidth: CGFloat = UIScreen.main.bounds.width, floorY: CGFloat = 600) {
        self.screenWidth = screenWidth
        self.floorY = floorY
    }
    
    public func start() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(step))
            displayLink?.preferredFramesPerSecond = 120
            displayLink?.add(to: .main, forMode: .common)
            lastUpdate = CACurrentMediaTime()
        }
    }
    
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // MARK: - User Interaction
    
    /// Spawns a bead at the top, acting like tapping a tasbih
    public func tap() {
        totalDhikrCount += 1
        
        // Haptic feedback via advanced manager
        TasbihHapticsManager.shared.playCollisionFeedback(intensity: 1.0)
        
        let newBead = Bead(
            position: CGPoint(x: screenWidth / 2 + CGFloat.random(in: -20...20), y: -50),
            velocity: CGVector(dx: CGFloat.random(in: -100...100), dy: CGFloat.random(in: 400...600)),
            radius: 20.0,
            mass: 1.0,
            restitution: 0.4,
            colorIndex: totalDhikrCount % 33 == 0 ? 1 : 0
        )
        
        beads.append(newBead)
        
        // Keep max beads on screen to 100 to prevent extreme lag
        if beads.count > 100 {
            beads.removeFirst()
        }
    }
    
    public func reset() {
        beads.removeAll()
        totalDhikrCount = 0
    }
    
    // MARK: - Simulation Step
    
    @objc private func step(link: CADisplayLink) {
        let currentTime = link.timestamp
        let dt = CGFloat(currentTime - lastUpdate)
        lastUpdate = currentTime
        
        // Prevent huge jumps if app lagged
        guard dt > 0 && dt < 0.1 else { return }
        
        simulate(dt: dt)
    }
    
    private func simulate(dt: CGFloat) {
        // We use Euler integration
        for i in 0..<beads.count {
            if beads[i].stopped { continue }
            
            // Apply Gravity
            beads[i].velocity.dy += gravity * dt
            
            // Apply Friction
            beads[i].velocity.dx *= friction
            beads[i].velocity.dy *= friction
            
            // Move
            beads[i].position.x += beads[i].velocity.dx * dt
            beads[i].position.y += beads[i].velocity.dy * dt
            
            // Bounds Check - Floor
            if beads[i].position.y + beads[i].radius > floorY {
                beads[i].position.y = floorY - beads[i].radius
                beads[i].velocity.dy *= -beads[i].restitution
                
                // Play floor hit sound if velocity is high enough
                let speed = abs(beads[i].velocity.dy)
                if speed > 50 {
                    let intensity = Float(speed / 800.0)
                    TasbihHapticsManager.shared.playCollisionFeedback(intensity: intensity, isWall: true)
                }
                
                // Sleep if very slow
                if speed < 15.0 && abs(beads[i].velocity.dx) < 15.0 {
                    beads[i].velocity = .zero
                    // Don't fully stop because other beads might hit it
                }
            }
            
            // Bounds Check - Walls
            if beads[i].position.x - beads[i].radius < 0 {
                beads[i].position.x = beads[i].radius
                beads[i].velocity.dx *= -beads[i].restitution
            } else if beads[i].position.x + beads[i].radius > screenWidth {
                beads[i].position.x = screenWidth - beads[i].radius
                beads[i].velocity.dx *= -beads[i].restitution
            }
        }
        
        // Resolve Bead-to-Bead Collisions (O(N^2) but fine for N < 150)
        resolveCollisions()
        
        // Trigger UI Update
        objectWillChange.send()
    }
    
    private func resolveCollisions() {
        for i in 0..<beads.count {
            for j in (i+1)..<beads.count {
                
                let dx = beads[j].position.x - beads[i].position.x
                let dy = beads[j].position.y - beads[i].position.y
                let distanceSq = dx*dx + dy*dy
                let minDistance = beads[i].radius + beads[j].radius
                
                if distanceSq < minDistance * minDistance {
                    let distance = sqrt(distanceSq)
                    let overlap = minDistance - distance
                    
                    if distance > 0 {
                        let nx = dx / distance
                        let ny = dy / distance
                        
                        let k = 0.5 // Push factor (equal mass)
                        
                        beads[i].position.x -= nx * overlap * k
                        beads[i].position.y -= ny * overlap * k
                        beads[j].position.x += nx * overlap * k
                        beads[j].position.y += ny * overlap * k
                        
                        // Relative velocity
                        let rvx = beads[j].velocity.dx - beads[i].velocity.dx
                        let rvy = beads[j].velocity.dy - beads[i].velocity.dy
                        
                        let velAlongNormal = rvx * nx + rvy * ny
                        
                        if velAlongNormal > 0 { continue }
                        
                        let e = min(beads[i].restitution, beads[j].restitution)
                        
                        var jImpulse = -(1 + e) * velAlongNormal
                        jImpulse /= (1 / beads[i].mass + 1 / beads[j].mass)
                        
                        let impulseX = nx * jImpulse
                        let impulseY = ny * jImpulse
                        
                        
                        beads[i].velocity.dx -= impulseX / beads[i].mass
                        beads[i].velocity.dy -= impulseY / beads[i].mass
                        beads[j].velocity.dx += impulseX / beads[j].mass
                        beads[j].velocity.dy += impulseY / beads[j].mass
                        
                        // Bead to bead collision sound
                        let collisionSpeed = sqrt(rvx*rvx + rvy*rvy)
                        if collisionSpeed > 40 {
                            let intensity = Float(collisionSpeed / 600.0)
                            TasbihHapticsManager.shared.playCollisionFeedback(intensity: intensity, isWall: false)
                        }
                    }
                }
            }
        }
    }
}
