import SpriteKit
import SwiftUI
import CoreHaptics

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TasbihSpriteKitScene — Hyper-Realistic Physics Engine
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Uses SpriteKit to simulate 33 or 99 beads connected by invisible 
// 'string' springs (SKPhysicsJointSpring), solving the "loose beads" 
// problem and creating an organic, pullable physical chain.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

public final class TasbihSpriteKitScene: SKScene, SKPhysicsContactDelegate {
    
    private var beads: [SKShapeNode] = []
    private let beadRadius: CGFloat = 22.0
    private let beadCount = 33
    
    private var anchorNode: SKNode!
    private var isEngineReady = false
    
    // External bindings
    public var onDhikrCounted: (() -> Void)?
    public var onMilestoneReached: (() -> Void)?
    
    // Drag state
    private var draggedNode: SKNode?
    
    override public func didMove(to view: SKView) {
        guard !isEngineReady else { return }
        
        self.backgroundColor = .clear
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.81) // Realistic Earth gravity
        self.physicsWorld.contactDelegate = self
        
        setupBoundaries()
        buildTasbihChain()
        
        isEngineReady = true
    }
    
    // MARK: - Scene Setup
    
    private func setupBoundaries() {
        // Create an invisible trough so beads pool beautifully at the bottom
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: beadRadius * 3))
        path.addQuadCurve(to: CGPoint(x: size.width, y: beadRadius * 3), control: CGPoint(x: size.width / 2, y: -beadRadius * 2))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        
        let containerNode = SKShapeNode(path: path)
        containerNode.strokeColor = .clear
        containerNode.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        containerNode.physicsBody?.restitution = 0.2
        containerNode.physicsBody?.friction = 0.6
        addChild(containerNode)
        
        // Top anchor where the tasbih hangs from (invisible hand)
        anchorNode = SKNode()
        anchorNode.position = CGPoint(x: size.width / 2, y: size.height - 100)
        anchorNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        anchorNode.physicsBody?.isDynamic = false // Fixed in space
        addChild(anchorNode)
    }
    
    private func buildTasbihChain() {
        var previousNode: SKNode = anchorNode
        
        for i in 0..<beadCount {
            let isImame = i == 0 || i == 11 || i == 22
            
            // Create the bead
            let bead = SKShapeNode(circleOfRadius: isImame ? beadRadius * 1.2 : beadRadius)
            bead.position = CGPoint(x: size.width / 2, y: size.height - 150 - CGFloat(i * Int(beadRadius * 2)))
            
            // Advanced Metal-like shading via SpriteKit
            bead.fillColor = isImame ? UIColor(DS.Color.warning) : UIColor(DS.Color.accent)
            bead.strokeColor = UIColor.white.withAlphaComponent(0.4)
            bead.lineWidth = 1.5
            bead.glowWidth = isImame ? 4.0 : 1.0
            
            // Physics Properties
            let pb = SKPhysicsBody(circleOfRadius: beadRadius)
            pb.mass = isImame ? 1.5 : 1.0
            pb.restitution = 0.5   // Bounciness
            pb.friction = 0.3      // Smoothness
            pb.linearDamping = 0.5 // Simulate air resistance & string tension
            pb.categoryBitMask = 1
            pb.contactTestBitMask = 1
            bead.physicsBody = pb
            
            addChild(bead)
            beads.append(bead)
            
            // Core Innovation: The String (SKPhysicsJointSpring)
            let joint = SKPhysicsJointSpring.joint(
                withBodyA: previousNode.physicsBody!,
                bodyB: bead.physicsBody!,
                anchorA: previousNode.position,
                anchorB: bead.position
            )
            
            // Tension settings
            joint.damping = 0.6
            joint.frequency = 20.0
            
            self.physicsWorld.add(joint)
            previousNode = bead
        }
    }
    
    // MARK: - Interaction (The organic pull)
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Find the node being touched
        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            if let bead = node as? SKShapeNode {
                draggedNode = bead
                bead.physicsBody?.isDynamic = false // Lock it to finger
                
                // Play soft touch haptic
                TasbihHapticsManager.shared.playCollisionFeedback(intensity: 0.3, isWall: false)
                break
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let node = draggedNode else { return }
        let location = touch.location(in: self)
        
        // Move the tapped node explicitly
        node.position = location
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        releaseBead()
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        releaseBead()
    }
    
    private func releaseBead() {
        if let node = draggedNode {
            node.physicsBody?.isDynamic = true // Restore physics
            draggedNode = nil
            
            // A bead was released (counted as a dhikr step)
            triggerDhikr()
        }
    }
    
    // MARK: - Mechanics
    
    private func triggerDhikr() {
        onDhikrCounted?()
        TasbihHapticsManager.shared.playCollisionFeedback(intensity: 1.0, isWall: false)
        
        // Impulsive jerk to the anchor to simulate string pull throughout the chain
        anchorNode.run(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 15, duration: 0.05),
            SKAction.moveBy(x: 0, y: -15, duration: 0.1)
        ]))
    }
    
    // MARK: - SKPhysicsContactDelegate
    
    public func didBegin(_ contact: SKPhysicsContact) {
        // Evaluate collision impact to trigger audio/haptics dynamically
        let impactVelocity = contact.collisionImpulse
        
        if impactVelocity > 50 {
            let intensity = min(Float(impactVelocity / 300.0), 1.0)
            TasbihHapticsManager.shared.playCollisionFeedback(intensity: intensity, isWall: false)
        }
    }
    
    // Provide a programmatic burst logic
    public func pullNextBead() {
        triggerDhikr()
        
        // Simulate a strong downward swipe on the middle of the chain
        let middleBead = beads[beads.count / 2]
        middleBead.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -300))
    }
}
