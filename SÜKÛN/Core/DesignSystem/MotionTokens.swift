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
}
