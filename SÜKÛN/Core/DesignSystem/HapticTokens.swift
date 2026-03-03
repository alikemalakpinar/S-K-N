import UIKit

extension DS {
    enum Haptic {
        private static var lastDhikrTap: CFAbsoluteTime = 0
        // ~12 taps/sec → minimum ~83ms between taps
        private static let minDhikrInterval: CFAbsoluteTime = 0.083

        /// Light tap for each dhikr count — like a bead sliding.
        static func dhikrTap() {
            let now = CFAbsoluteTimeGetCurrent()
            guard now - lastDhikrTap >= minDhikrInterval else { return }
            lastDhikrTap = now

            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.prepare()
            gen.impactOccurred()
        }

        /// Medium tap for milestone counts (33, 66, 99) — nişane hissi.
        static func dhikrMilestone() {
            let gen = UIImpactFeedbackGenerator(style: .heavy)
            gen.prepare()
            gen.impactOccurred(intensity: 1.0)
        }

        /// Success notification for reaching a dhikr goal.
        static func goalReached() {
            let gen = UINotificationFeedbackGenerator()
            gen.prepare()
            gen.notificationOccurred(.success)
        }
    }
}
