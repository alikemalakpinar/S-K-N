import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TasbihPhysicsView — Render layer for the 2D physics engine
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

public struct TasbihPhysicsView: View {
    @StateObject private var engine: TasbihPhysicsEngine
    @Environment(\.colorScheme) private var scheme
    
    public init() {
        _engine = StateObject(wrappedValue: TasbihPhysicsEngine(
            screenWidth: UIScreen.main.bounds.width,
            floorY: UIScreen.main.bounds.height - 250 // Floor is above the control button
        ))
    }
    
    public var body: some View {
        ZStack {
            DS.Color.backgroundPrimary.ignoresSafeArea()
            
            // Physics Render Canvas
            Canvas { context, size in
                for bead in engine.beads {
                    let rect = CGRect(
                        x: bead.position.x - bead.radius,
                        y: bead.position.y - bead.radius,
                        width: bead.radius * 2,
                        height: bead.radius * 2
                    )
                    let path = Path(ellipseIn: rect)
                    
                    let isSpecial = bead.colorIndex == 1
                    let baseColor = isSpecial ? DS.Color.warning : DS.Color.accent
                    
                    // Render premium glassy spherical bead
                    context.fill(
                        path,
                        with: .radialGradient(
                            Gradient(colors: [baseColor, baseColor.opacity(0.3)]),
                            center: CGPoint(x: bead.position.x - bead.radius*0.3, y: bead.position.y - bead.radius*0.3),
                            startRadius: 0,
                            endRadius: bead.radius
                        )
                    )
                    context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: 1)
                }
            }
            .ignoresSafeArea()
            
            // Front UI Overlay
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("ZİKİR")
                            .font(DS.Typography.sectionHead)
                            .foregroundStyle(DS.Color.accent)
                        Text(String(format: "%04d", engine.totalDhikrCount))
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(DS.Color.textPrimary)
                            .contentTransition(.numericText())
                    }
                    Spacer()
                    Button {
                        engine.reset()
                        DS.Haptic.softTap()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(DS.Color.textSecondary)
                            .padding()
                            .background(Circle().fill(DS.Color.glassFill))
                    }
                }
                .padding(DS.Space.x3)
                
                Spacer()
                
                // The Master Tap Button
                Button {
                    engine.tap()
                } label: {
                    ZStack {
                        Circle()
                            .fill(DS.Color.accent)
                            .frame(width: 120, height: 120)
                            .shadow(color: DS.Color.accent.opacity(0.5), radius: 20, y: 10)
                        
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, DS.Space.x3)
            }
        }
        .onAppear {
            engine.start()
        }
        .onDisappear {
            engine.stop()
        }
    }
}

#Preview {
    TasbihPhysicsView()
}
