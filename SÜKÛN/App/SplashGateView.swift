import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SplashGateView — Cinematic App Entry 
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Replaces the standard static launch screen with a 120 FPS
// fluid, particle-enhanced logo reveal before routing.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SplashGateView: View {
    let container: DependencyContainer
    @Binding var hasCompletedOnboarding: Bool
    
    @State private var phase: SplashPhase = .initial
    @Namespace private var splashSpace
    
    enum SplashPhase {
        case initial
        case breathing
        case exploding
        case routed
    }
    
    init(container: DependencyContainer, hasCompletedOnboarding: Binding<Bool>) {
        self.container = container
        self._hasCompletedOnboarding = hasCompletedOnboarding
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
                .transition(.opacity.animation(.easeInOut(duration: 1.0)))
            } else {
                // Cinematic Splash Content
                ZStack {
                    // Deep immersive background
                    DS.Color.backgroundPrimary.ignoresSafeArea()
                    FluidBackgroundView()
                        .opacity(phase == .exploding ? 0 : 0.8)
                    
                    VStack(spacing: DS.Space.lg) {
                        // The Logo
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [DS.Color.accent.opacity(0.8), .clear],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: phase == .exploding ? 800 : (phase == .breathing ? 150 : 50)
                                    )
                                )
                                .frame(width: 300, height: 300)
                                .opacity(phase == .exploding ? 0 : 1)
                            
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: phase == .exploding ? 300 : (phase == .initial ? 60 : 80)))
                                .foregroundStyle(DS.Color.accent)
                                .shadow(color: DS.Color.accent.opacity(0.6), radius: phase == .initial ? 0 : 30, y: 0)
                                .matchedGeometryEffect(id: "logo", in: splashSpace)
                                .opacity(phase == .exploding ? 0 : 1)
                        }
                        
                        // Typeface
                        Text("S Ü K Û N")
                            .font(.system(size: 28, weight: .black, design: .serif))
                            .foregroundStyle(DS.Color.textPrimary)
                            .tracking(phase == .exploding ? 40 : (phase == .breathing ? 15 : 5))
                            .opacity(phase == .exploding ? 0 : 1)
                    }
                }
                .onAppear {
                    runCinematicSequence()
                }
            }
        }
    }
    
    private func runCinematicSequence() {
        DS.Haptic.softTap()
        
        // 1. Initial breath
        withAnimation(.easeInOut(duration: 1.2)) {
            phase = .breathing
        }
        
        // 2. Explode out
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            DS.Haptic.success()
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0)) {
                phase = .exploding
            }
            
            // 3. Route
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    phase = .routed
                }
            }
        }
    }
}
