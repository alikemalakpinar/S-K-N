import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// QiblaCompassView — 3D Mathematical Spatial Rendering constraints
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Harnessing CoreMotion and hundreds of ticks to visually mimic a 
// physical titanium compass with extreme depth.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

public struct QiblaCompassView: View {
    @StateObject private var engine = QiblaEngineService()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Immersively Deep Background
            DS.Color.surfaceImmersive.ignoresSafeArea()
            
            VStack(spacing: DS.Space.xl) {
                
                // Header Metrics
                VStack(spacing: DS.Space.sm) {
                    Text("KIBLE PUSULASI")
                        .font(DS.Typography.sectionHead)
                        .foregroundStyle(DS.Color.accent)
                        .tracking(3)
                    
                    if let error = engine.errorStatus {
                        Text(error)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(DS.Color.warning)
                            .multilineTextAlignment(.center)
                            .padding()
                            .dsGlass(.thin, cornerRadius: DS.Radius.md)
                    }
                }
                .padding(.top, DS.Space.x3)
                
                Spacer()
                
                // The Masterpiece 3D Compass
                compassDial
                    // 3D Tilt Effect using Gyroscope
                    .rotation3DEffect(
                        .degrees(engine.pitch * 30),
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .rotation3DEffect(
                        .degrees(engine.roll * 30),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 30, x: CGFloat(engine.roll * 30), y: CGFloat(engine.pitch * 30))
                
                Spacer()
                
                // Mathematical Accuracy readout
                VStack(spacing: DS.Space.sm) {
                    Text("Kıble Açısı: \(String(format: "%.1f°", engine.qiblaHeading))")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundStyle(DS.Color.textSecondary)
                    
                    Text(engine.isAccuracyOptimized ? "Hassasiyet: OPTİMUM" : "Hassasiyet: DÜŞÜK")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(engine.isAccuracyOptimized ? DS.Color.success : DS.Color.warning)
                }
                .padding(.bottom, DS.Space.x3)
            }
        }
        .onAppear {
            engine.requestPermissions()
        }
    }
    
    // MARK: - Mathematical Dial Drawings
    
    private var compassDial: some View {
        ZStack {
            // Main Titanium Bezel
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DS.Color.backgroundSecondary, DS.Color.backgroundPrimary],
                        center: .center,
                        startRadius: 50,
                        endRadius: 180
                    )
                )
                .frame(width: 320, height: 320)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [DS.Color.accent, DS.Color.accent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: DS.Color.accent.opacity(0.15), radius: 20, y: 10)
            
            // 360 Degree Tick Marks
            ForEach(0..<120) { tick in
                let angle = Double(tick) * 3.0
                let isMajor = tick % 10 == 0
                
                Rectangle()
                    .fill(isMajor ? DS.Color.accent : DS.Color.textTertiary)
                    .frame(width: isMajor ? 3 : 1, height: isMajor ? 14 : 7)
                    .offset(y: -140)
                    .rotationEffect(.degrees(angle))
            }
            
            // Text Directions (N, E, S, W)
            let directions = [("K", 0.0), ("D", 90.0), ("G", 180.0), ("B", 270.0)]
            ForEach(directions, id: \.1) { dir in
                Text(dir.0)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(dir.0 == "K" ? DS.Color.accent : DS.Color.textPrimary)
                    .offset(y: -110)
                    .rotationEffect(.degrees(dir.1))
            }
            
            // Rotate the entire dial based strictly on mathematical inverse heading
            .rotationEffect(.degrees(-engine.currentHeading))
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.8), value: engine.currentHeading)
            
            // The Kaaba Arrow (Fixed orientation relative to Qibla angle)
            KaabaPointer()
                .offset(y: -90)
                .rotationEffect(.degrees(engine.angleToQibla))
                .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.6), value: engine.angleToQibla)
        }
        .frame(width: 350, height: 350)
    }
}

// MARK: - Subcomponents

private struct KaabaPointer: View {
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "location.north.fill")
                .font(.system(size: 32))
                .foregroundStyle(DS.Color.accent)
                .shadow(color: DS.Color.accent.opacity(0.6), radius: pulse ? 12 : 4, y: pulse ? -4 : 0)
                .scaleEffect(pulse ? 1.05 : 1.0)
            
            Text("KÂBE")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(DS.Color.accent)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
