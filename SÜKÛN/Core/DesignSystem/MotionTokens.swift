import SwiftUI
import UIKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN Design System — Motion Tokens
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  Motion in SÜKÛN is intentional and calm. Every animation
//  follows Apple's spring system for natural physics, with
//  graceful reduce-motion fallbacks throughout.
//
//  response  → how fast it settles (lower = snappier)
//  damping   → how much it overshoots (lower = bouncier)
//  blendDuration → smooth transitions when interrupted
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension DS {
    enum Motion {

        // ── Accessibility ────────────────────────────────────
        private static var reduceMotion: Bool {
            UIAccessibility.isReduceMotionEnabled
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Core Animations
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Standard spring — cards appearing, sections expanding, general layout shifts.
        /// Smooth and confident, like a door closing gently.
        static var standard: Animation {
            reduceMotion
                ? .easeOut(duration: 0.15)
                : .spring(response: 0.42, dampingFraction: 0.88, blendDuration: 0.1)
        }

        /// Quick tap response — button presses, toggles, prayer pills.
        /// Immediate and crisp, minimal overshoot.
        static var tap: Animation {
            reduceMotion
                ? .easeOut(duration: 0.10)
                : .spring(response: 0.30, dampingFraction: 0.80, blendDuration: 0)
        }

        /// Verse transitions — expanding a verse, highlighting, focus shifts.
        /// Gentle ease that feels like turning a page.
        static var verse: Animation {
            reduceMotion
                ? .easeOut(duration: 0.12)
                : .easeInOut(duration: 0.28)
        }

        /// Countdown tick — numeric text transitions in timers.
        /// Ultra-smooth, no bounce, just clean number rolling.
        static var countdown: Animation {
            reduceMotion
                ? .easeOut(duration: 0.08)
                : .easeOut(duration: 0.18)
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Interactive Springs
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Bouncy spring — onboarding elements, celebrations, goal reached.
        /// Playful overshoot that communicates delight.
        static var bouncy: Animation {
            reduceMotion
                ? .easeOut(duration: 0.20)
                : .spring(response: 0.50, dampingFraction: 0.65, blendDuration: 0)
        }

        /// Snappy spring — drag release, sheet dismiss, quick snaps.
        /// Fast settle with barely perceptible bounce.
        static var snappy: Animation {
            reduceMotion
                ? .easeOut(duration: 0.12)
                : .spring(response: 0.28, dampingFraction: 0.86, blendDuration: 0)
        }

        /// Slow reveal — hero elements appearing on screen, dashboard load.
        /// Graceful entrance that draws the eye without rushing.
        static var slowReveal: Animation {
            reduceMotion
                ? .easeOut(duration: 0.20)
                : .spring(response: 0.65, dampingFraction: 0.90, blendDuration: 0.15)
        }

        /// Elastic spring — compass needle, qibla arrow, physics-based UI.
        /// Natural wobble like a physical instrument settling.
        static var elastic: Animation {
            reduceMotion
                ? .easeOut(duration: 0.15)
                : .spring(response: 0.55, dampingFraction: 0.60, blendDuration: 0)
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Page & Navigation
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Page swipe — Mushaf reader page transitions.
        /// Quick but smooth, matching iOS native paging feel.
        static var pageSwipe: Animation {
            reduceMotion
                ? .easeOut(duration: 0.15)
                : .spring(response: 0.38, dampingFraction: 0.92, blendDuration: 0.05)
        }

        /// Sheet presentation — bottom sheets sliding up.
        /// Smooth deceleration like iOS native sheets.
        static var sheet: Animation {
            reduceMotion
                ? .easeOut(duration: 0.20)
                : .spring(response: 0.48, dampingFraction: 0.88, blendDuration: 0.1)
        }

        /// Tab switch — instant feel with subtle settle.
        static var tabSwitch: Animation {
            reduceMotion
                ? .easeOut(duration: 0.08)
                : .spring(response: 0.25, dampingFraction: 0.90, blendDuration: 0)
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Stagger Factory
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Returns a standard animation with stagger delay for list/grid items.
        /// - Parameter index: Item position in the list (0-based).
        /// - Parameter interval: Delay between each item (default 0.06s).
        static func stagger(index: Int, interval: Double = 0.06) -> Animation {
            reduceMotion
                ? .easeOut(duration: 0.15)
                : standard.delay(Double(index) * interval)
        }

        /// Returns a slow-reveal animation with stagger for hero sections.
        static func heroStagger(index: Int, interval: Double = 0.10) -> Animation {
            reduceMotion
                ? .easeOut(duration: 0.20)
                : slowReveal.delay(Double(index) * interval)
        }

        // ── GSAP-Inspired Stagger Patterns ────────────────────

        /// Center-out stagger: items in the middle appear first, edges last.
        /// Inspired by GSAP's `stagger: { from: "center" }` pattern.
        static func staggerFromCenter(index: Int, total: Int, interval: Double = 0.06) -> Animation {
            let center = Double(total - 1) / 2.0
            let distance = abs(Double(index) - center)
            return reduceMotion
                ? .easeOut(duration: 0.15)
                : standard.delay(distance * interval)
        }

        /// Random stagger: each item gets a deterministic pseudo-random delay.
        /// Inspired by GSAP's `stagger: { from: "random" }` pattern.
        static func staggerRandom(seed: Int, maxDelay: Double = 0.4) -> Animation {
            let pseudoRandom = Double((seed &* 1103515245 &+ 12345) & 0x7FFFFFFF) / Double(0x7FFFFFFF)
            return reduceMotion
                ? .easeOut(duration: 0.15)
                : standard.delay(pseudoRandom * maxDelay)
        }

        /// Cascade stagger with elastic overshoot — for grid items, celebrations.
        /// Inspired by GSAP's elastic ease with stagger.
        static func elasticStagger(index: Int, interval: Double = 0.08) -> Animation {
            reduceMotion
                ? .easeOut(duration: 0.15)
                : .spring(response: 0.55, dampingFraction: 0.60).delay(Double(index) * interval)
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Premium Transitions
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Dramatic hero entrance — oversized elements scaling in with cinematic weight.
        /// For splash screens, achievement celebrations, milestone moments.
        static var dramaticEntrance: Animation {
            reduceMotion
                ? .easeOut(duration: 0.25)
                : .spring(response: 0.70, dampingFraction: 0.72, blendDuration: 0.15)
        }

        /// Silk smooth — ultra-refined easing for premium UI transitions.
        /// Feels like high-end physical materials sliding into place.
        static var silk: Animation {
            reduceMotion
                ? .easeOut(duration: 0.18)
                : .spring(response: 0.45, dampingFraction: 0.92, blendDuration: 0.08)
        }

        /// Magnetic snap — for elements locking into position (Qibla, grid alignment).
        static var magneticSnap: Animation {
            reduceMotion
                ? .easeOut(duration: 0.12)
                : .spring(response: 0.22, dampingFraction: 0.78, blendDuration: 0)
        }

        /// Celebration bounce — exaggerated for goal reached, milestone, achievement.
        static var celebration: Animation {
            reduceMotion
                ? .easeOut(duration: 0.25)
                : .spring(response: 0.55, dampingFraction: 0.55, blendDuration: 0)
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Breathing & Immersive
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Continuous breathing animation — gentle scale cycle (1.0 → 1+scale → 1.0).
        /// For dhikr ring, prayer pulse, meditation elements.
        static func breathing(duration: Double = 4.0) -> Animation {
            reduceMotion
                ? .linear(duration: 0)
                : .easeInOut(duration: duration).repeatForever(autoreverses: true)
        }

        /// Ripple expand — single outward ring that fades.
        static var ripple: Animation {
            reduceMotion
                ? .easeOut(duration: 0.10)
                : .easeOut(duration: 0.8)
        }

        /// Ambient fade — slow dimming for ambient/idle mode.
        static var ambient: Animation {
            reduceMotion
                ? .easeOut(duration: 0.15)
                : .easeInOut(duration: 1.5)
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Raw Durations
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // For non-Animation use (CAAnimation, Timer, withAnimation closures).

        static let standardDuration:  Double = 0.42
        static let tapDuration:       Double = 0.30
        static let verseDuration:     Double = 0.28
        static let countdownDuration: Double = 0.18
        static let bouncyDuration:    Double = 0.50
        static let pageSwipeDuration: Double = 0.38

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Transition Presets
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Fade + scale up from 0.95 — cards appearing.
        static var appearTransition: AnyTransition {
            .opacity
            .combined(with: .scale(scale: 0.95))
            .combined(with: .offset(y: 8))
        }

        /// Slide from bottom + fade — sheet-like entry.
        static var slideUpTransition: AnyTransition {
            .move(edge: .bottom)
            .combined(with: .opacity)
        }

        /// Scale from center — celebration / milestone popups.
        static var popTransition: AnyTransition {
            .scale(scale: 0.8)
            .combined(with: .opacity)
        }

        /// Horizontal slide — page-like navigation.
        static var slideLeadingTransition: AnyTransition {
            .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        }

        /// Blur dissolve — premium frosted glass reveal effect.
        static var blurDissolve: AnyTransition {
            .opacity
            .combined(with: .scale(scale: 1.02))
        }

        /// Hero zoom — dramatic entrance for full-screen modals.
        static var heroZoom: AnyTransition {
            .scale(scale: 0.88)
            .combined(with: .opacity)
        }
    }
}

// MARK: - View Modifier Conveniences

extension View {
    /// Animate appearance with stagger delay.
    /// Usage: `.dsAppear(loaded: isLoaded, index: 2)`
    func dsAppear(loaded: Bool, index: Int = 0, interval: Double = 0.06) -> some View {
        opacity(loaded ? 1 : 0)
            .offset(y: loaded ? 0 : 12)
            .animation(DS.Motion.stagger(index: index, interval: interval), value: loaded)
    }

    /// Smooth scale-on-press effect for interactive elements.
    /// Usage: `.dsPress(isPressed: configuration.isPressed)`
    func dsPress(_ isPressed: Bool, scale: CGFloat = 0.97) -> some View {
        scaleEffect(isPressed ? scale : 1.0)
            .animation(DS.Motion.tap, value: isPressed)
    }

    /// Continuous breathing scale animation for meditation elements.
    /// Usage: `.dsBreathing(active: isActive)`
    func dsBreathing(active: Bool, scale: CGFloat = 1.02, duration: Double = 4.0) -> some View {
        scaleEffect(active ? scale : 1.0)
            .animation(
                active ? DS.Motion.breathing(duration: duration) : .default,
                value: active
            )
    }

    /// Shimmer highlight effect — sweeping light across surfaces for premium feel.
    func dsShimmer(active: Bool) -> some View {
        modifier(ShimmerHighlightModifier(active: active))
    }

    /// Float animation — gentle vertical hover for featured elements.
    func dsFloat(active: Bool, amplitude: CGFloat = 6, duration: Double = 3.0) -> some View {
        offset(y: active ? -amplitude : amplitude)
            .animation(
                active
                    ? .easeInOut(duration: duration).repeatForever(autoreverses: true)
                    : .default,
                value: active
            )
    }

    /// Scroll-triggered reveal: fades in + slides up when view appears on screen.
    /// Inspired by GSAP ScrollTrigger's reveal pattern.
    /// Usage: `.dsScrollReveal(index: 2)` for staggered scroll reveals.
    func dsScrollReveal(index: Int = 0, interval: Double = 0.08) -> some View {
        modifier(ScrollRevealModifier(index: index, interval: interval))
    }

    /// PhaseAnimator-driven entrance for cards.
    /// Usage: `.dsPhaseEntrance(trigger: appeared)`
    @ViewBuilder
    func dsPhaseEntrance(trigger: Bool) -> some View {
        if UIAccessibility.isReduceMotionEnabled {
            self.opacity(trigger ? 1 : 0)
        } else {
            self
                .phaseAnimator(
                    EntrancePhase.allCases,
                    trigger: trigger
                ) { content, phase in
                    content
                        .opacity(phase.opacity)
                        .scaleEffect(phase.scale)
                        .offset(y: phase.offsetY)
                } animation: { phase in
                    switch phase {
                    case .initial: nil
                    case .appear: .spring(response: 0.45, dampingFraction: 0.82)
                    case .settle: .spring(response: 0.30, dampingFraction: 0.90)
                    }
                }
        }
    }
}

// MARK: - Entrance Phase (PhaseAnimator)

/// Three-phase entrance for rich card animations.
enum EntrancePhase: CaseIterable {
    case initial, appear, settle

    var opacity: Double {
        switch self {
        case .initial: 0
        case .appear: 1
        case .settle: 1
        }
    }

    var scale: CGFloat {
        switch self {
        case .initial: 0.92
        case .appear: 1.02
        case .settle: 1.0
        }
    }

    var offsetY: CGFloat {
        switch self {
        case .initial: 16
        case .appear: -2
        case .settle: 0
        }
    }
}

// MARK: - Number Morph Values (KeyframeAnimator)

/// Values for animating number transitions (lift-up + scale + settle).
struct NumberMorphValues {
    var scale: Double = 1.0
    var offsetY: Double = 0
    var opacity: Double = 1.0
}

// MARK: - Scroll Reveal Modifier (GSAP ScrollTrigger-Inspired)

/// Animates content into view with a fade + slide when it first appears.
struct ScrollRevealModifier: ViewModifier {
    let index: Int
    let interval: Double
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .scaleEffect(hasAppeared ? 1 : 0.96)
            .onAppear {
                let delay = Double(index) * interval
                withAnimation(DS.Motion.slowReveal.delay(delay)) {
                    hasAppeared = true
                }
            }
    }
}

// MARK: - Animation Timeline (GSAP Timeline-Inspired)

/// Utility for choreographing sequential animations.
/// Inspired by GSAP's timeline concept.
///
/// Usage:
/// ```swift
/// AnimationTimeline.run([
///     (0.0, { withAnimation(DS.Motion.bouncy) { showIcon = true } }),
///     (0.2, { withAnimation(DS.Motion.standard) { showTitle = true } }),
///     (0.4, { withAnimation(DS.Motion.slowReveal) { showSubtitle = true } }),
/// ])
/// ```
enum AnimationTimeline {
    static func run(_ steps: [(delay: Double, action: () -> Void)]) {
        for step in steps {
            if step.delay == 0 {
                step.action()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + step.delay) {
                    step.action()
                }
            }
        }
    }
}

// MARK: - Shimmer Highlight Modifier

/// Sweeping light highlight effect for premium card surfaces.
struct ShimmerHighlightModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                if active && !UIAccessibility.isReduceMotionEnabled {
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.08),
                                .white.opacity(0.15),
                                .white.opacity(0.08),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: phase * geo.size.width * 1.5)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 2.5)
                                .repeatForever(autoreverses: false)
                            ) {
                                phase = 1
                            }
                        }
                    }
                    .clipped()
                    .allowsHitTesting(false)
                }
            }
    }
}

// MARK: - Scroll Offset Preference Key

/// Tracks scroll position for scroll-driven animations (parallax, header collapse).
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
