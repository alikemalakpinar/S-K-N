import SwiftUI
import UIKit

extension DS {
    enum Motion {
        private static var reduceMotion: Bool {
            UIAccessibility.isReduceMotionEnabled
        }

        static var standard: Animation {
            reduceMotion
                ? .easeOut(duration: 0.15)
                : .spring(response: 0.45, dampingFraction: 0.9)
        }
        static var tap: Animation {
            reduceMotion
                ? .easeOut(duration: 0.1)
                : .spring(response: 0.35, dampingFraction: 0.82)
        }
        static var verse: Animation {
            reduceMotion
                ? .easeOut(duration: 0.1)
                : .easeOut(duration: 0.25)
        }
        static var countdown: Animation {
            reduceMotion
                ? .easeOut(duration: 0.1)
                : .easeOut(duration: 0.2)
        }

        // Raw durations for non-animation use
        static let standardDuration:  Double = 0.45
        static let tapDuration:       Double = 0.35
        static let verseDuration:     Double = 0.25
        static let countdownDuration: Double = 0.2
    }
}
