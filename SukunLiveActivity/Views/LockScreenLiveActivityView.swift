import SwiftUI
import WidgetKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN — Lock Screen Live Activity Banner
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  Premium Lock Screen presentation with:
//  • .ultraThinMaterial frosted glass background
//  • Large crisp countdown typography
//  • Gold-gradient animated progress indicator
//  • Warm gold accent matching the SÜKÛN design system
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct LockScreenLiveActivityView: View {
    @Environment(\.colorScheme) var colorScheme
    let context: ActivityViewContext<PrayerAttributes>

    var body: some View {
        VStack(spacing: 14) {

            // ── Top Row: Prayer Name | Location + Time ────────
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("SONRAKİ NAMAZ")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(LAColor.textSecondary(for: colorScheme))
                        .tracking(2)

                    Text(context.state.prayerName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(LAColor.textPrimary(for: colorScheme))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    if !context.attributes.locationName.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 8))
                            Text(context.attributes.locationName)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(LAColor.textSecondary(for: colorScheme))
                    }

                    Text(context.state.prayerTime, format: .dateTime.hour().minute())
                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                        .foregroundStyle(LAColor.accent(for: colorScheme))
                }
            }

            // ── Countdown Timer — Hero ────────────────────────
            Text(timerInterval: Date.now...context.state.prayerTime, countsDown: true)
                .monospacedDigit()
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(LAColor.textPrimary(for: colorScheme))
                .frame(maxWidth: .infinity)

            // ── Progress Bar ──────────────────────────────────
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(LAColor.hairline(for: colorScheme))
                        .frame(height: 5)

                    // Fill — gold gradient
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    LAColor.accent(for: colorScheme).opacity(0.4),
                                    LAColor.accent(for: colorScheme)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(5, geo.size.width * context.state.progress),
                            height: 5
                        )

                    // Glow dot at progress tip
                    if context.state.progress > 0.02 {
                        Circle()
                            .fill(LAColor.accent(for: colorScheme))
                            .frame(width: 7, height: 7)
                            .shadow(
                                color: LAColor.accent(for: colorScheme).opacity(0.6),
                                radius: 4
                            )
                            .offset(x: geo.size.width * context.state.progress - 3.5)
                    }
                }
            }
            .frame(height: 7)

            // ── Bottom Row: Following Prayer ──────────────────
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(LAColor.accent(for: colorScheme))

                if let following = context.state.followingPrayerName {
                    Text("Sonraki: \(following)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(LAColor.textSecondary(for: colorScheme))
                } else {
                    Text("Son vakit")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(LAColor.textSecondary(for: colorScheme))
                }

                Spacer()

                // Sükûn brand mark
                Text("Sükûn")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(LAColor.textSecondary(for: colorScheme).opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .activityBackgroundTint(LAColor.background(for: colorScheme).opacity(0.6))
    }
}
