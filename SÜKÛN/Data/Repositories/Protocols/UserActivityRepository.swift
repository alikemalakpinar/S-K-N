import Foundation
import SwiftData

protocol UserActivityRepository {
    func prayerLog(for date: Date, context: ModelContext) throws -> PrayerLog?
    func getOrCreatePrayerLog(for date: Date, context: ModelContext) throws -> PrayerLog
    func upsertPrayerLog(_ log: PrayerLog, context: ModelContext) throws
    func readingLogs(from: Date, to: Date, context: ModelContext) throws -> [ReadingLog]
    func addReadingLog(_ log: ReadingLog, context: ModelContext) throws
    func counterSessions(from: Date, to: Date, context: ModelContext) throws -> [CounterSession]

    // Last read position
    func getLastReadPosition(context: ModelContext) throws -> LastReadPosition?
    func saveLastReadPosition(page: Int, surahId: Int, verseNumber: Int, surahName: String, context: ModelContext) throws

    // Page read tracking
    func logPageRead(page: Int, context: ModelContext) throws
    func pagesReadToday(context: ModelContext) throws -> Int
    func totalUniquePagesRead(context: ModelContext) throws -> Int
    func readingStreakDays(context: ModelContext) throws -> Int
}
