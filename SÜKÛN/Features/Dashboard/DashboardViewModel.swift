import Foundation
import SwiftData

@Observable
final class DashboardViewModel {
    var nextPrayerName: String = "--"
    var nextPrayerTime: Date?
    var todayLog: PrayerLog?
    var isLoading = false
    var errorMessage: String?

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadTodayData(context: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        // Load today's prayer log (upsert prevents duplicates)
        do {
            todayLog = try container.userActivityRepository.getOrCreatePrayerLog(for: Date(), context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadNextPrayer(latitude: Double, longitude: Double, method: String, asrMethod: String) async {
        do {
            let today = try await container.prayerTimeService.todayPrayerTimes(
                latitude: latitude,
                longitude: longitude,
                method: method,
                asrMethod: asrMethod
            )
            if let next = container.prayerTimeService.nextPrayer(from: today, after: Date()) {
                nextPrayerName = next.name
                nextPrayerTime = next.time

                // Update widget data
                try? container.widgetDataService.writeNextPrayerData(name: next.name, time: next.time)
            } else {
                nextPrayerName = "Isha"
                nextPrayerTime = today.isha
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
