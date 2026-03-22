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
                            .font(DS.Typography.alongSans(size: 13, weight: "Medium"))
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
            // Outer ambient glow ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DS.Color.accent.opacity(0.05), .clear],
                        center: .center,
                        startRadius: 150,
                        endRadius: 200
                    )
                )
                .frame(width: 360, height: 360)

            // Main Titanium Bezel — dual-ring design
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DS.Color.backgroundSecondary,
                            DS.Color.backgroundPrimary.opacity(0.95),
                            DS.Color.backgroundPrimary
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 170
                    )
                )
                .frame(width: 320, height: 320)
                .overlay(
                    ZStack {
                        // Inner bezel ring
                        Circle()
                            .stroke(DS.Color.hairline.opacity(0.3), lineWidth: 1)
                            .frame(width: 300, height: 300)

                        // Outer bezel ring — premium gradient
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        DS.Color.accent.opacity(0.6),
                                        DS.Color.accent.opacity(0.1),
                                        DS.Color.accent.opacity(0.3),
                                        DS.Color.accent.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                    }
                )
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                .shadow(color: DS.Color.accent.opacity(0.1), radius: 30, y: 0)

            // 360 Degree Tick Marks — finer detail
            ForEach(0..<120) { tick in
                let angle = Double(tick) * 3.0
                let isMajor = tick % 10 == 0
                let isMedium = tick % 5 == 0

                Rectangle()
                    .fill(
                        isMajor
                            ? DS.Color.accent.opacity(0.8)
                            : isMedium
                                ? DS.Color.textSecondary.opacity(0.4)
                                : DS.Color.textTertiary.opacity(0.5)
                    )
                    .frame(
                        width: isMajor ? 2.5 : (isMedium ? 1.5 : 0.8),
                        height: isMajor ? 16 : (isMedium ? 10 : 5)
                    )
                    .offset(y: -140)
                    .rotationEffect(.degrees(angle))
            }

            // Degree numbers at 30° intervals
            ForEach(0..<12) { i in
                let deg = i * 30
                if deg % 90 != 0 {
                    Text("\(deg)")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(DS.Color.textTertiary)
                        .offset(y: -120)
                        .rotationEffect(.degrees(Double(deg)))
                }
            }

            // Cardinal directions — premium typography
            let directions: [(String, Double, Bool)] = [
                ("K", 0.0, true), ("D", 90.0, false),
                ("G", 180.0, false), ("B", 270.0, false)
            ]
            ForEach(directions, id: \.1) { dir in
                Text(dir.0)
                    .font(.system(size: dir.2 ? 26 : 22, weight: .black, design: .rounded))
                    .foregroundStyle(
                        dir.2
                            ? DS.Color.accent
                            : DS.Color.textPrimary.opacity(0.7)
                    )
                    .shadow(color: dir.2 ? DS.Color.accent.opacity(0.3) : .clear, radius: 6)
                    .offset(y: -105)
                    .rotationEffect(.degrees(dir.1))
            }

            // Rotate the entire dial
            .rotationEffect(.degrees(-engine.currentHeading))
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.8), value: engine.currentHeading)

            // Center hub — layered metallic effect
            ZStack {
                Circle()
                    .fill(DS.Color.accent.opacity(0.1))
                    .frame(width: 20, height: 20)
                    .blur(radius: 4)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [DS.Color.accent.opacity(0.6), DS.Color.accent],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 6
                        )
                    )
                    .frame(width: 10, height: 10)
                    .shadow(color: DS.Color.accent.opacity(0.5), radius: 4)
            }

            // The Kaaba Arrow
            KaabaPointer()
                .offset(y: -90)
                .rotationEffect(.degrees(engine.angleToQibla))
                .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.6), value: engine.angleToQibla)
        }
        .frame(width: 360, height: 360)
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
                .font(DS.Typography.chipLabel)
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
