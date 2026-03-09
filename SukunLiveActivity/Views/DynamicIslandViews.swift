import SwiftUI
import WidgetKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN — Dynamic Island Views
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MARK: - Compact Leading (Crescent Icon)

struct CompactLeadingView: View {
    var body: some View {
        Image(systemName: "moon.stars.fill")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.yellow.opacity(0.9))
    }
}

// MARK: - Compact Trailing (Countdown Timer)

struct CompactTrailingView: View {
    let state: PrayerAttributes.ContentState

    var body: some View {
        Text(timerInterval: Date.now...state.prayerTime, countsDown: true)
            .monospacedDigit()
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(minWidth: 36)
    }
}

// MARK: - Minimal (Countdown Only)

struct MinimalView: View {
    let state: PrayerAttributes.ContentState

    var body: some View {
        Text(timerInterval: Date.now...state.prayerTime, countsDown: true)
            .monospacedDigit()
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }
}

// MARK: - Expanded Leading (Prayer Name)

struct ExpandedLeadingView: View {
    let state: PrayerAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("SONRAKİ")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)

            Text(state.prayerName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
    }
}

// MARK: - Expanded Trailing (Exact Time)

struct ExpandedTrailingView: View {
    let state: PrayerAttributes.ContentState

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("VAKİT")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)

            Text(state.prayerTime, format: .dateTime.hour().minute())
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(.yellow.opacity(0.9))
        }
    }
}

// MARK: - Expanded Center (Large Countdown)

struct ExpandedCenterView: View {
    let state: PrayerAttributes.ContentState

    var body: some View {
        Text(timerInterval: Date.now...state.prayerTime, countsDown: true)
            .monospacedDigit()
            .font(.system(size: 32, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }
}

// MARK: - Expanded Bottom (Progress Bar + Following Prayer)

struct ExpandedBottomView: View {
    let state: PrayerAttributes.ContentState

    var body: some View {
        VStack(spacing: 10) {
            // Progress bar with gold gradient
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(.white.opacity(0.12))
                        .frame(height: 4)

                    // Fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .yellow.opacity(0.5),
                                    .yellow.opacity(0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(4, geo.size.width * state.progress),
                            height: 4
                        )

                    // Glow dot at end
                    if state.progress > 0.02 {
                        Circle()
                            .fill(.yellow)
                            .frame(width: 6, height: 6)
                            .shadow(color: .yellow.opacity(0.6), radius: 3)
                            .offset(x: geo.size.width * state.progress - 3)
                    }
                }
            }
            .frame(height: 6)

            // Following prayer hint
            if let following = state.followingPrayerName {
                HStack {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text("Sonraki: \(following)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
    }
}
