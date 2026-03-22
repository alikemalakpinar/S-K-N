import Foundation
import SwiftData

@Observable
final class JourneyViewModel {
    // Animated counters — start at 0 for counting effect
    var totalPagesRead = 0
    var readingStreak = 0
    var hatimProgress: Double = 0
    var totalDhikrCount = 0
    var totalPrayersLogged = 0

    // Weekly activity dots (last 7 days)
    var weeklyActivity: [DayActivity] = []

    // Milestones
    var milestones: [Milestone] = []

    // Loading state
    var isLoaded = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    struct DayActivity: Identifiable {
        let id = UUID()
        let date: Date
        let dayLabel: String
        let hasPrayer: Bool
        let hasReading: Bool
        let hasDhikr: Bool
    }

    struct Milestone: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let subtitle: String
        let isAchieved: Bool
        let color: String // "accent", "success", "warning"
    }

    func loadStats(context: ModelContext) {
        Task { @MainActor in
            do {
                let repo = container.userActivityRepository
                let cal = Calendar.current

                // Core stats
                totalPagesRead = try repo.totalUniquePagesRead(context: context)
                readingStreak = try repo.readingStreakDays(context: context)
                hatimProgress = Double(totalPagesRead) / 604.0

                // Dhikr (last 30 days)
                let thirtyDaysAgo = cal.date(byAdding: .day, value: -30, to: .now) ?? .now
                let sessions = try repo.counterSessions(from: thirtyDaysAgo, to: .now, context: context)
                totalDhikrCount = sessions.reduce(0) { $0 + $1.count }

                // Prayer count (last 7 days)
                var prayerCount = 0
                for dayOffset in 0..<7 {
                    let day = cal.date(byAdding: .day, value: -dayOffset, to: .now) ?? .now
                    if let log = try repo.prayerLog(for: day, context: context) {
                        prayerCount += [log.fajr, log.dhuhr, log.asr, log.maghrib, log.isha]
                            .filter { $0 == .prayed }
                            .count
                    }
                }
                totalPrayersLogged = prayerCount

                // Weekly activity
                let dayLabels = L10n.Tracker.weekDays
                var week: [DayActivity] = []
                for dayOffset in (0..<7).reversed() {
                    let day = cal.date(byAdding: .day, value: -dayOffset, to: .now) ?? .now
                    let nextDay = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: day)) ?? .now
                    let startOfDay = cal.startOfDay(for: day)

                    let hasPrayer: Bool
                    if let log = try repo.prayerLog(for: day, context: context) {
                        hasPrayer = [log.fajr, log.dhuhr, log.asr, log.maghrib, log.isha]
                            .contains(where: { $0 == .prayed })
                    } else {
                        hasPrayer = false
                    }

                    let dayReadingLogs = try repo.readingLogs(from: startOfDay, to: nextDay, context: context)
                    let daySessions = sessions.filter { $0.date >= startOfDay && $0.date < nextDay }

                    let weekday = cal.component(.weekday, from: day)
                    let idx = (weekday + 5) % 7

                    week.append(DayActivity(
                        date: day,
                        dayLabel: dayLabels[idx],
                        hasPrayer: hasPrayer,
                        hasReading: !dayReadingLogs.isEmpty,
                        hasDhikr: !daySessions.isEmpty
                    ))
                }
                weeklyActivity = week

                // Milestones
                milestones = buildMilestones()

                isLoaded = true
            } catch {
                isLoaded = true // Degrade gracefully
            }
        }
    }

    private func buildMilestones() -> [Milestone] {
        var m: [Milestone] = []

        // Hatim milestones
        m.append(Milestone(
            icon: "book.fill",
            title: L10n.Journey.milestoneFirstJuz,
            subtitle: L10n.Journey.milestonePagesOf(20, 604),
            isAchieved: totalPagesRead >= 20,
            color: "accent"
        ))
        m.append(Milestone(
            icon: "book.closed.fill",
            title: L10n.Journey.milestoneQuarterHatim,
            subtitle: L10n.Journey.milestonePagesOf(151, 604),
            isAchieved: totalPagesRead >= 151,
            color: "accent"
        ))
        m.append(Milestone(
            icon: "star.fill",
            title: L10n.Journey.milestoneHalfHatim,
            subtitle: L10n.Journey.milestonePagesOf(302, 604),
            isAchieved: totalPagesRead >= 302,
            color: "success"
        ))

        // Streak milestones
        m.append(Milestone(
            icon: "flame.fill",
            title: L10n.Journey.milestoneWeekStreak,
            subtitle: L10n.Journey.milestoneStreakDays(7),
            isAchieved: readingStreak >= 7,
            color: "warning"
        ))
        m.append(Milestone(
            icon: "flame.circle.fill",
            title: L10n.Journey.milestoneMonthStreak,
            subtitle: L10n.Journey.milestoneStreakDays(30),
            isAchieved: readingStreak >= 30,
            color: "warning"
        ))

        // Dhikr milestones
        m.append(Milestone(
            icon: "circle.circle.fill",
            title: L10n.Journey.milestoneDhikr1000,
            subtitle: L10n.Journey.milestoneDhikrCount(1000),
            isAchieved: totalDhikrCount >= 1000,
            color: "accent"
        ))

        return m
    }
}
