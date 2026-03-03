import Foundation
import SwiftData

protocol UserActivityRepository {
    func prayerLog(for date: Date, context: ModelContext) throws -> PrayerLog?
    func upsertPrayerLog(_ log: PrayerLog, context: ModelContext) throws
    func readingLogs(from: Date, to: Date, context: ModelContext) throws -> [ReadingLog]
    func addReadingLog(_ log: ReadingLog, context: ModelContext) throws
    func counterSessions(from: Date, to: Date, context: ModelContext) throws -> [CounterSession]
}
