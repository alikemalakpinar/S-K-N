import UIKit

extension DS {
    enum Haptic {
        private static var lastDhikrTap: CFAbsoluteTime = 0
        // ~12 taps/sec → minimum ~83ms between taps
        private static let minDhikrInterval: CFAbsoluteTime = 0.083

        /// Light tap for each dhikr count. Throttled to prevent spam (>12/sec).
        static func dhikrTap() {
            let now = CFAbsoluteTimeGetCurrent()
            guard now - lastDhikrTap >= minDhikrInterval else { return }
            lastDhikrTap = now

            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.prepare()
            gen.impactOccurred()
        }

        /// Success notification for reaching a dhikr goal.
        static func goalReached() {
            let gen = UINotificationFeedbackGenerator()
            gen.prepare()
            gen.notificationOccurred(.success)
        }
    }
}
