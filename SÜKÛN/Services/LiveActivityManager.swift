import ActivityKit
import Foundation

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN — Live Activity Lifecycle Manager
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  Manages start / update / end of the Next Prayer Live Activity.
//  Local-only updates (no APNs push) — the main app's periodic
//  timer keeps the progress bar and prayer transition up to date.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

protocol LiveActivityManagerProtocol: Sendable {
    /// Start a new Live Activity showing the next prayer countdown.
    func startLiveActivity(
        prayerName: String,
        prayerTime: Date,
        followingPrayerName: String?,
        progress: Double,
        locationName: String
    ) throws

    /// Update the running Live Activity with new prayer data / progress.
    func updateLiveActivity(
        prayerName: String,
        prayerTime: Date,
        followingPrayerName: String?,
        progress: Double
    ) async

    /// End the Live Activity immediately.
    func endLiveActivity() async

    /// Whether there is currently a running Live Activity.
    var isLiveActivityActive: Bool { get }
}

// MARK: - Implementation

final class LiveActivityManager: LiveActivityManagerProtocol, Sendable {

    var isLiveActivityActive: Bool {
        !Activity<PrayerAttributes>.activities.isEmpty
    }

    func startLiveActivity(
        prayerName: String,
        prayerTime: Date,
        followingPrayerName: String?,
        progress: Double,
        locationName: String
    ) throws {
        // End any existing activity first
        Task { await endLiveActivity() }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.notAuthorized
        }

        let attributes = PrayerAttributes(locationName: locationName)
        let state = PrayerAttributes.ContentState(
            prayerName: prayerName,
            prayerTime: prayerTime,
            followingPrayerName: followingPrayerName,
            progress: progress
        )

        let content = ActivityContent(
            state: state,
            staleDate: prayerTime   // Mark as stale once prayer time arrives
        )

        _ = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil           // Local-only — no APNs
        )
    }

    func updateLiveActivity(
        prayerName: String,
        prayerTime: Date,
        followingPrayerName: String?,
        progress: Double
    ) async {
        let state = PrayerAttributes.ContentState(
            prayerName: prayerName,
            prayerTime: prayerTime,
            followingPrayerName: followingPrayerName,
            progress: progress
        )
        let content = ActivityContent(
            state: state,
            staleDate: prayerTime
        )

        for activity in Activity<PrayerAttributes>.activities {
            await activity.update(content)
        }
    }

    func endLiveActivity() async {
        for activity in Activity<PrayerAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}

// MARK: - Error

enum LiveActivityError: LocalizedError {
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Canlı Etkinlikler cihaz ayarlarında devre dışı."
        }
    }
}
