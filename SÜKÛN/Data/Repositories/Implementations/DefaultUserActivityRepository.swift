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
}
