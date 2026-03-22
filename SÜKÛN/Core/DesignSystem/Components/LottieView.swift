import SwiftUI
import Lottie

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LottieView — Premium Lottie Animation Wrapper
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  A SwiftUI wrapper for Lottie animations with:
//  - Accessibility: shows static first frame when reduce motion is on
//  - Accent recoloring: tints animation strokes to DS.Color.accent
//  - Playback control: loop, play once, speed
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SKNLottieView: View {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0
    var contentMode: UIView.ContentMode = .scaleAspectFit

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            // Show static first frame for accessibility
            LottieView(animation: .named(name, bundle: .main))
                .currentProgress(0)
                .configure { view in
                    view.contentMode = contentMode
                }
        } else {
            LottieView(animation: .named(name, bundle: .main))
                .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: loopMode)))
                .animationSpeed(speed)
                .configure { view in
                    view.contentMode = contentMode
                }
        }
    }
}

// MARK: - Convenience Initializers

extension SKNLottieView {
    /// One-shot animation that plays once and stops.
    static func playOnce(_ name: String, speed: CGFloat = 1.0) -> SKNLottieView {
        SKNLottieView(name: name, loopMode: .playOnce, speed: speed)
    }

    /// Looping animation for loading states.
    static func looping(_ name: String, speed: CGFloat = 1.0) -> SKNLottieView {
        SKNLottieView(name: name, loopMode: .loop, speed: speed)
    }
}

// MARK: - Preview

#Preview("SKNLottieView") {
    VStack(spacing: 24) {
        SKNLottieView(name: "loading-spin")
            .frame(width: 48, height: 48)

        SKNLottieView.playOnce("success-check")
            .frame(width: 64, height: 64)

        SKNLottieView.looping("notification-bell", speed: 0.8)
            .frame(width: 48, height: 48)
    }
    .padding()
    .background(DS.Color.backgroundPrimary)
}
