import Foundation
import SwiftData

@Observable
final class ProfileViewModel {
    // Stats
    var totalPagesRead = 0
    var readingStreak = 0
    var hatimProgress: Double = 0
    var totalDhikrCount = 0
    var todayPrayerCount = 0

    // Prayer detail
    var todayPrayerLog: PrayerLog?

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadStats(context: ModelContext) {
        Task { @MainActor in
            do {
                let repo = container.userActivityRepository
                totalPagesRead = try repo.totalUniquePagesRead(context: context)
                readingStreak = try repo.readingStreakDays(context: context)
                hatimProgress = Double(totalPagesRead) / 604.0

                // Today's prayer log
                todayPrayerLog = try repo.prayerLog(for: .now, context: context)
                if let log = todayPrayerLog {
                    todayPrayerCount = [log.fajr, log.dhuhr, log.asr, log.maghrib, log.isha]
                        .filter { $0 == .prayed }
                        .count
                }

                // Recent dhikr (last 30 days)
                let cal = Calendar.current
                let thirtyDaysAgo = cal.date(byAdding: .day, value: -30, to: .now) ?? .now
                let sessions = try repo.counterSessions(from: thirtyDaysAgo, to: .now, context: context)
                totalDhikrCount = sessions.reduce(0) { $0 + $1.count }
            } catch {
                // Degrade gracefully — leave at zero defaults
            }
        }
    }
}
