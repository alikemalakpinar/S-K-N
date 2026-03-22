import UIKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN Design System — Haptic Tokens
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  Every interaction in SÜKÛN has a tactile signature.
//  These haptics map to spiritual micro-moments:
//  a bead sliding, a page turning, a prayer logged.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension DS {
    enum Haptic {
        // ── Throttle State ───────────────────────────────────
        private static var lastDhikrTap: CFAbsoluteTime = 0
        private static let minDhikrInterval: CFAbsoluteTime = 0.075

        // ── Pre-warmed Generators ────────────────────────────
        // Reusing generators avoids allocation overhead on hot paths.
        private static let lightEngine  = UIImpactFeedbackGenerator(style: .light)
        private static let mediumEngine = UIImpactFeedbackGenerator(style: .medium)
        private static let heavyEngine  = UIImpactFeedbackGenerator(style: .heavy)
        private static let softEngine   = UIImpactFeedbackGenerator(style: .soft)
        private static let rigidEngine  = UIImpactFeedbackGenerator(style: .rigid)
        private static let selectionEngine = UISelectionFeedbackGenerator()
        private static let notificationEngine = UINotificationFeedbackGenerator()

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Dhikr (Zikir)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Light tap for each dhikr count — like a bead sliding.
        /// Throttled to ~13 taps/sec to prevent engine saturation.
        static func dhikrTap() {
            let now = CFAbsoluteTimeGetCurrent()
            guard now - lastDhikrTap >= minDhikrInterval else { return }
            lastDhikrTap = now
            lightEngine.impactOccurred(intensity: 0.65)
        }

        /// Firm pulse at milestone counts (33, 66, 99).
        static func dhikrMilestone() {
            heavyEngine.impactOccurred(intensity: 1.0)
        }

        /// Success burst when a dhikr goal is reached.
        static func goalReached() {
            notificationEngine.notificationOccurred(.success)
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: UI Micro-interactions
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Soft tap — button presses, card selections, general UI taps.
        static func softTap() {
            softEngine.impactOccurred(intensity: 0.5)
        }

        /// Selection tick — segment changes, picker scrolling, toggle flips.
        static func selection() {
            selectionEngine.selectionChanged()
        }

        /// Medium impact — toggling prayer status, tab switching.
        static func mediumTap() {
            mediumEngine.impactOccurred(intensity: 0.7)
        }

        /// Rigid snap — confirming an action, locking in a choice.
        static func snap() {
            rigidEngine.impactOccurred(intensity: 0.8)
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Notifications
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Success vibration — prayer logged, bookmark saved.
        static func success() {
            notificationEngine.notificationOccurred(.success)
        }

        /// Warning vibration — calibration needed, error state.
        static func warning() {
            notificationEngine.notificationOccurred(.warning)
        }

        /// Error vibration — action failed, invalid input.
        static func error() {
            notificationEngine.notificationOccurred(.error)
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Complex Patterns
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Page turn — soft double-tap like paper being turned.
        static func pageTurn() {
            softEngine.impactOccurred(intensity: 0.35)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                lightEngine.impactOccurred(intensity: 0.25)
            }
        }

        /// Prayer complete — ascending triple pulse (sabah→öğle→ikindi feeling).
        static func prayerComplete() {
            lightEngine.impactOccurred(intensity: 0.4)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                mediumEngine.impactOccurred(intensity: 0.6)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                heavyEngine.impactOccurred(intensity: 0.9)
            }
        }

        /// Qibla locked — strong pulse when phone aligns with Qibla direction.
        static func qiblaLocked() {
            rigidEngine.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                rigidEngine.impactOccurred(intensity: 0.6)
            }
        }

        /// Countdown finish — when the prayer time arrives.
        static func countdownFinish() {
            heavyEngine.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                notificationEngine.notificationOccurred(.success)
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Preparation
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Call before a known interaction to reduce latency.
        /// Warms the Taptic Engine so the first tap feels instant.
        static func prepare() {
            lightEngine.prepare()
            mediumEngine.prepare()
            selectionEngine.prepare()
        }

        /// Prepare the heavy engine for milestone/goal haptics.
        static func prepareMilestone() {
            heavyEngine.prepare()
            notificationEngine.prepare()
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Immersive Patterns
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        /// Tab switch haptic — crisp selection for switching tabs.
        static func tabSwitch() {
            rigidEngine.impactOccurred(intensity: 0.4)
        }

        /// Particle burst — celebration for milestone particle effects.
        static func particleBurst() {
            heavyEngine.impactOccurred(intensity: 0.9)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                softEngine.impactOccurred(intensity: 0.3)
            }
        }

        /// Long press progress — escalating feedback during hold gestures.
        static func longPressProgress(intensity: CGFloat) {
            mediumEngine.impactOccurred(intensity: min(1.0, intensity))
        }

        /// Celebration cascade — ascending four-pulse celebration pattern.
        /// For major milestones like completing a Hatim, 1000 dhikr, etc.
        static func celebrationCascade() {
            lightEngine.impactOccurred(intensity: 0.3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                mediumEngine.impactOccurred(intensity: 0.5)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                heavyEngine.impactOccurred(intensity: 0.8)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                notificationEngine.notificationOccurred(.success)
            }
        }

        /// Gentle heartbeat — warm double-pulse for intimate spiritual moments.
        static func heartbeat() {
            mediumEngine.impactOccurred(intensity: 0.6)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                heavyEngine.impactOccurred(intensity: 0.8)
            }
        }
    }
}
