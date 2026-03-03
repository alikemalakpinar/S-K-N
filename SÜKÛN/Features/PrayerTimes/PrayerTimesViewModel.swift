import Foundation

@Observable
final class PrayerTimesViewModel {
    var todayTimes: PrayerDay?
    var upcomingDays: [PrayerDay] = []
    var isLoading = false
    var errorMessage: String?

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadPrayerTimes(latitude: Double, longitude: Double, method: String, asrMethod: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let days = try await container.prayerTimeService.computeAndCache(
                latitude: latitude,
                longitude: longitude,
                method: method,
                asrMethod: asrMethod
            )
            todayTimes = days.first
            upcomingDays = days
        } catch {
            errorMessage = error.localizedDescription

            // Try loading from cache
            if let cached = await container.prayerTimeService.loadCached() {
                todayTimes = cached.first
                upcomingDays = cached
            }
        }
    }
}
