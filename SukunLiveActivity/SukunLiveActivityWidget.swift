import ActivityKit
import WidgetKit
import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN — Next Prayer Live Activity Widget
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  Provides all Live Activity presentations:
//  • Lock Screen banner
//  • Dynamic Island — compact, minimal, expanded
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SukunLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerAttributes.self) { context in

            // ── Lock Screen Presentation ──────────────────────
            LockScreenLiveActivityView(context: context)

        } dynamicIsland: { context in
            DynamicIsland {
                // ── Expanded State ────────────────────────────
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(state: context.state)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(state: context.state)
                }
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(state: context.state)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(state: context.state)
                }
            } compactLeading: {
                // ── Compact Leading — Crescent Icon ───────────
                CompactLeadingView()
            } compactTrailing: {
                // ── Compact Trailing — Countdown Timer ────────
                CompactTrailingView(state: context.state)
            } minimal: {
                // ── Minimal — Countdown Only ──────────────────
                MinimalView(state: context.state)
            }
        }
    }
}
