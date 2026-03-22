import SwiftUI
import SpriteKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TasbihSpriteView — Container for Hyper-Realistic Physics
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

public struct TasbihSpriteView: View {
    @State private var dhikrCount: Int = 0
    @State private var scene: TasbihSpriteKitScene
    
    public init() {
        let createdScene = TasbihSpriteKitScene()
        createdScene.size = UIScreen.main.bounds.size
        createdScene.scaleMode = .resizeFill
        _scene = State(initialValue: createdScene)
    }
    
    public var body: some View {
        ZStack {
            DS.Color.backgroundPrimary.ignoresSafeArea()
            
            // Core Innovation: The physically string-bound beads
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()
            
            // Ultra Premium HUD
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("ZİKİR")
                            .font(DS.Typography.sectionHead)
                            .foregroundStyle(DS.Color.accent)
                        Text(String(format: "%04d", dhikrCount))
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundStyle(DS.Color.textPrimary)
                            .contentTransition(.numericText())
                    }
                    Spacer()
                    Button {
                        dhikrCount = 0
                        DS.Haptic.softTap()
                        // Reset Scene here if needed
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
                
                // Big digital pull button
                Button {
                    scene.pullNextBead()
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
            scene.onDhikrCounted = {
                withAnimation {
                    dhikrCount += 1
                }
            }
        }
    }
}
