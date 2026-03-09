import ActivityKit
import Foundation

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN — Prayer Live Activity Attributes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  ⚠️  TARGET MEMBERSHIP: This file MUST belong to BOTH
//      the main "SÜKÛN" target AND the "SukunLiveActivity"
//      widget extension target.
//
//      In Xcode → File Inspector → Target Membership →
//      check both targets.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct PrayerAttributes: ActivityAttributes {

    // ── Dynamic State (changes with each update) ──────────────
    struct ContentState: Codable, Hashable {
        /// Turkish name of the upcoming prayer (e.g. "İkindi")
        let prayerName: String

        /// Exact time the prayer begins
        let prayerTime: Date

        /// Name of the following prayer (e.g. "Akşam"), shown as hint
        let followingPrayerName: String?

        /// 0.0 → 1.0 progress through the current inter-prayer period.
        /// Computed by the main app; the widget extension only renders it.
        let progress: Double
    }

    // ── Static Attributes (set once when activity starts) ─────
    /// City/country display string (e.g. "İstanbul, Türkiye")
    let locationName: String
}
