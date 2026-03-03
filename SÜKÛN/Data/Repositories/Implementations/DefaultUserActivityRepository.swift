import Foundation
import SwiftData

final class DefaultUserActivityRepository: UserActivityRepository {

    func prayerLog(for date: Date, context: ModelContext) throws -> PrayerLog? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<PrayerLog> { log in
            log.date >= startOfDay && log.date < endOfDay
        }
        let descriptor = FetchDescriptor<PrayerLog>(predicate: predicate)
        return try context.fetch(descriptor).first
    }

    func getOrCreatePrayerLog(for date: Date, context: ModelContext) throws -> PrayerLog {
        let startOfDay = Calendar.current.startOfDay(for: date)
        if let existing = try prayerLog(for: startOfDay, context: context) {
            return existing
        }
        let newLog = PrayerLog(date: startOfDay)
        context.insert(newLog)
        try context.save()
        return newLog
    }

    func upsertPrayerLog(_ log: PrayerLog, context: ModelContext) throws {
        context.insert(log)
        try context.save()
    }

    func readingLogs(from start: Date, to end: Date, context: ModelContext) throws -> [ReadingLog] {
        let predicate = #Predicate<ReadingLog> { log in
            log.date >= start && log.date <= end
        }
        let descriptor = FetchDescriptor<ReadingLog>(
            predicate: predicate,
            sortBy: [SortDescriptor(\ReadingLog.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func addReadingLog(_ log: ReadingLog, context: ModelContext) throws {
        context.insert(log)
        try context.save()
    }

    func counterSessions(from start: Date, to end: Date, context: ModelContext) throws -> [CounterSession] {
        let predicate = #Predicate<CounterSession> { session in
            session.date >= start && session.date <= end
        }
        let descriptor = FetchDescriptor<CounterSession>(
            predicate: predicate,
            sortBy: [SortDescriptor(\CounterSession.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    // MARK: - Last Read Position

    func getLastReadPosition(context: ModelContext) throws -> LastReadPosition? {
        let predicate = #Predicate<LastReadPosition> { $0.id == "current" }
        let descriptor = FetchDescriptor<LastReadPosition>(predicate: predicate)
        return try context.fetch(descriptor).first
    }

    func saveLastReadPosition(page: Int, surahId: Int, verseNumber: Int, surahName: String, context: ModelContext) throws {
        let predicate = #Predicate<LastReadPosition> { $0.id == "current" }
        let descriptor = FetchDescriptor<LastReadPosition>(predicate: predicate)
        let position: LastReadPosition
        if let existing = try context.fetch(descriptor).first {
            position = existing
        } else {
            position = LastReadPosition()
            context.insert(position)
        }
        position.mushafPage = page
        position.surahId = surahId
        position.verseNumber = verseNumber
        position.surahNameTurkish = surahName
        position.updatedAt = Date()
        try context.save()
    }

    // MARK: - Page Read Tracking

    func logPageRead(page: Int, context: ModelContext) throws {
        let log = PageReadLog(pageNumber: page)
        context.insert(log)
        try context.save()
    }

    func pagesReadToday(context: ModelContext) throws -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = #Predicate<PageReadLog> { $0.date >= startOfDay && $0.date < endOfDay }
        let descriptor = FetchDescriptor<PageReadLog>(predicate: predicate)
        let logs = try context.fetch(descriptor)
        let uniquePages = Set(logs.map { $0.pageNumber })
        return uniquePages.count
    }

    func totalUniquePagesRead(context: ModelContext) throws -> Int {
        let descriptor = FetchDescriptor<PageReadLog>()
        let logs = try context.fetch(descriptor)
        let uniquePages = Set(logs.map { $0.pageNumber })
        return uniquePages.count
    }

    func readingStreakDays(context: ModelContext) throws -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: checkDate)!
            let predicate = #Predicate<PageReadLog> { $0.date >= checkDate && $0.date < nextDay }
            let descriptor = FetchDescriptor<PageReadLog>(predicate: predicate)
            let logs = try context.fetch(descriptor)
            if logs.isEmpty {
                break
            }
            streak += 1
            guard let prevDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prevDay
        }

        return streak
    }
}
