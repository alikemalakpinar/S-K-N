import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FluidBackgroundView — Ultra-premium Interactive 120FPS Background
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Hooks into the ParticleEngine to render fluid light bursts 
// using SwiftUI Canvas, mimicking a majestic soul-like atmosphere.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

public struct FluidBackgroundView: View {
    @StateObject private var engine = ParticleEngine(particleCount: 156)
    @State private var touchLocation: CGPoint? = nil
    
    public init() {}
    
    public var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 120.0)) { context in
                Canvas(
                    opaque: false,
                    colorMode: .linear,
                    rendersAsynchronously: true
                ) { graphicsContext, size in
                    
                    engine.update(
                        in: size,
                        time: context.date.timeIntervalSinceReferenceDate,
                        touchPoint: touchLocation
                    )
                    
                    let bgColors = DS.Color.timeGradient()
                    let baseColor1 = bgColors[0]
                    let baseColor2 = bgColors[1]
                    
                    // Draw base dynamic mesh simulation via gradient
                    let globalGradient = Gradient(colors: [
                        baseColor1.opacity(0.8),
                        baseColor2.opacity(1.0)
                    ])
                    let rect = CGRect(origin: .zero, size: size)
                    graphicsContext.fill(
                        Path(rect),
                        with: .linearGradient(
                            globalGradient,
                            startPoint: .zero,
                            endPoint: CGPoint(x: size.width, y: size.height)
                        )
                    )
                    
                    // Add immersive blend mode for particles
                    graphicsContext.blendMode = .screen
                    
                    // Resolve Symbols & render millions of pixels securely via caching
                    for p in engine.particles {
                        let position = CGPoint(x: CGFloat(p.position.x), y: CGFloat(p.position.y))
                        let radius = CGFloat(p.size)
                        let rect = CGRect(x: position.x - radius, y: position.y - radius, width: radius * 2, height: radius * 2)
                        
                        let particleGradient = Gradient(colors: [
                            DS.Color.accent.opacity(p.colorOpacity * p.life),
                            .clear
                        ])
                        
                        let path = Path(ellipseIn: rect)
                        graphicsContext.fill(
                            path,
                            with: .radialGradient(
                                particleGradient,
                                center: position,
                                startRadius: 0,
                                endRadius: radius
                            )
                        )
                    }
                }
            }
            // Real-time extreme fidelity touch interaction
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        touchLocation = value.location
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 1.5)) {
                            touchLocation = nil
                        }
                    }
            )
            .ignoresSafeArea()
            // Imbue with an epic blur to smooth out the flocking into fluid
            .blur(radius: 8.0, opaque: false)
        }
    }
}
