import Foundation
import SwiftData

@Observable
final class TrackerViewModel {
    var recentReadingLogs: [ReadingLog] = []
    var recentSessions: [CounterSession] = []

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadRecentActivity(context: ModelContext) {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        recentReadingLogs = (try? container.userActivityRepository.readingLogs(from: weekAgo, to: Date(), context: context)) ?? []
        recentSessions = (try? container.userActivityRepository.counterSessions(from: weekAgo, to: Date(), context: context)) ?? []
    }
}
