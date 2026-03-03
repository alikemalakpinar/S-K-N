import SwiftUI

extension DS {
    enum Motion {
        static let standard  = Animation.spring(response: 0.45, dampingFraction: 0.9)
        static let tap       = Animation.spring(response: 0.35, dampingFraction: 0.82)
        static let verse     = Animation.easeOut(duration: 0.25)
        static let countdown = Animation.easeOut(duration: 0.2)

        // Raw durations for non-animation use
        static let standardDuration:  Double = 0.45
        static let tapDuration:       Double = 0.35
        static let verseDuration:     Double = 0.25
        static let countdownDuration: Double = 0.2
    }
}
