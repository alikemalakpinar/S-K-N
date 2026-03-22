import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SplashGateView — Cinematic App Entry
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5-phase cinematic reveal: darkness → glow → breathe → burst → route.
// Every phase is choreographed with haptics and spring physics.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SplashGateView: View {
    let container: DependencyContainer
    @Binding var hasCompletedOnboarding: Bool

    @State private var phase: SplashPhase = .darkness
    @State private var ringScale: CGFloat = 0.6
    @State private var ringOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textTracking: CGFloat = 2
    @State private var subtitleOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var burstScale: CGFloat = 1
    @State private var burstOpacity: Double = 1

    enum SplashPhase: Equatable {
        case darkness
        case glow
        case breathe
        case burst
        case routed
    }

    var body: some View {
        ZStack {
            if phase == .routed {
                Group {
                    if hasCompletedOnboarding {
                        RootView(container: container)
                    } else {
                        OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding, container: container)
                    }
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.8)))
            } else {
                splashContent
            }
        }
    }

    // MARK: - Cinematic Splash

    private var splashContent: some View {
        ZStack {
            // Layer 0: Deep black → warm background fade
            DS.Color.backgroundPrimary.ignoresSafeArea()

            // Layer 1: Fluid particle canvas (subtle)
            FluidBackgroundView()
                .opacity(phase == .burst ? 0 : (phase == .darkness ? 0 : 0.6))
                .animation(.easeInOut(duration: 1.0), value: phase)

            // Layer 2: Concentric rings
            concentricRings

            // Layer 3: Logo + Text
            VStack(spacing: DS.Space.x2) {
                // Crescent moon icon
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DS.Color.accent, DS.Color.accent.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: DS.Color.accent.opacity(0.5), radius: glowRadius, y: 0)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // Brand name
                VStack(spacing: DS.Space.sm) {
                    Text("S Ü K Û N")
                        .font(DS.Typography.alongSans(size: 32, weight: "Black"))
                        .foregroundStyle(DS.Color.textPrimary)
                        .tracking(textTracking)
                        .opacity(textOpacity)

                    // Tagline
                    Text("Huzurlu bir ibadet deneyimi")
                        .font(DS.Typography.cormorant(size: 15, weight: "Italic"))
                        .foregroundStyle(DS.Color.textSecondary)
                        .opacity(subtitleOpacity)
                }
            }
            .scaleEffect(burstScale)
            .opacity(burstOpacity)
        }
        .onAppear { runCinematicSequence() }
    }

    // MARK: - Concentric Rings

    private var concentricRings: some View {
        ZStack {
            // Ornamental geometric pattern — 5 concentric rings with alternating styles
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                DS.Color.accent.opacity(ringOpacity * (1.0 - Double(i) * 0.18)),
                                DS.Color.accent.opacity(ringOpacity * (0.5 - Double(i) * 0.08))
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: i % 2 == 0
                            ? StrokeStyle(lineWidth: 0.5)
                            : StrokeStyle(lineWidth: 0.3, dash: [4, 6])
                    )
                    .frame(
                        width: CGFloat(100 + i * 50),
                        height: CGFloat(100 + i * 50)
                    )
                    .scaleEffect(ringScale + CGFloat(i) * 0.03)
                    .rotationEffect(.degrees(Double(i) * 15))
            }

            // Small ornamental dots on the innermost ring
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(DS.Color.accent.opacity(ringOpacity * 0.5))
                    .frame(width: 3, height: 3)
                    .offset(y: -50)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .scaleEffect(ringScale)
            }
        }
        .opacity(phase == .burst ? 0 : 1)
    }

    // MARK: - Cinematic Sequence

    private func runCinematicSequence() {
        AnimationTimeline.run([
            // Phase 1: Glow — rings materialize, logo emerges from darkness
            (0.3, {
                phase = .glow
                DS.Haptic.softTap()
                withAnimation(.easeOut(duration: 1.2)) {
                    ringOpacity = 0.5
                    ringScale = 1.0
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.72)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
            }),

            // Phase 2: Breathe — brand name unfurls with dramatic tracking
            (1.4, {
                phase = .breathe
                DS.Haptic.heartbeat()
                withAnimation(.easeOut(duration: 1.0)) {
                    textOpacity = 1.0
                    textTracking = 14
                    glowRadius = 50
                }
            }),

            // Subtitle materializes softly
            (2.0, {
                withAnimation(.easeOut(duration: 0.7)) {
                    subtitleOpacity = 1.0
                }
            }),

            // Phase 3: Burst — cinematic expand + dissolve
            (3.0, {
                phase = .burst
                DS.Haptic.celebrationCascade()
                withAnimation(.spring(response: 0.7, dampingFraction: 0.78)) {
                    burstScale = 1.2
                    burstOpacity = 0
                    ringOpacity = 0
                }
            }),

            // Phase 4: Route — seamless crossfade to app
            (3.6, {
                withAnimation(.easeInOut(duration: 0.6)) {
                    phase = .routed
                }
            })
        ])
    }
}
