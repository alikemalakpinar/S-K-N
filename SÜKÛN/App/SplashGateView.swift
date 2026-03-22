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
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        DS.Color.accent.opacity(ringOpacity * (1.0 - Double(i) * 0.3)),
                        lineWidth: 0.5
                    )
                    .frame(width: CGFloat(120 + i * 60), height: CGFloat(120 + i * 60))
                    .scaleEffect(ringScale + CGFloat(i) * 0.05)
            }
        }
        .opacity(phase == .burst ? 0 : 1)
    }

    // MARK: - Cinematic Sequence

    private func runCinematicSequence() {
        // Phase 1: Glow — rings fade in, logo appears (0.0s)
        AnimationTimeline.run([
            (0.3, {
                phase = .glow
                DS.Haptic.softTap()
                withAnimation(.easeOut(duration: 1.0)) {
                    ringOpacity = 0.4
                    ringScale = 1.0
                }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
            }),

            // Phase 2: Breathe — text reveals, glow pulses (1.2s)
            (1.2, {
                phase = .breathe
                withAnimation(.easeOut(duration: 0.8)) {
                    textOpacity = 1.0
                    textTracking = 12
                    glowRadius = 40
                }
            }),

            // Subtitle appears (1.8s)
            (1.8, {
                withAnimation(.easeOut(duration: 0.6)) {
                    subtitleOpacity = 1.0
                }
            }),

            // Phase 3: Burst — everything expands and fades (2.6s)
            (2.6, {
                phase = .burst
                DS.Haptic.success()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    burstScale = 1.15
                    burstOpacity = 0
                    ringOpacity = 0
                }
            }),

            // Phase 4: Route (3.2s)
            (3.2, {
                withAnimation(.easeInOut(duration: 0.5)) {
                    phase = .routed
                }
            })
        ])
    }
}
