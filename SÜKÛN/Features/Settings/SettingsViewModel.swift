import Foundation
import SwiftData

@Observable
final class SettingsViewModel {
    var settings: UserSetting?
    var notificationAuthorized = false
    var errorMessage: String?

    let calculationMethods = [
        "MuslimWorldLeague", "NorthAmerica", "Egyptian", "Karachi",
        "UmmAlQura", "Dubai", "Kuwait", "Qatar", "Singapore", "Turkey", "Tehran"
    ]

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadSettings(context: ModelContext) {
        let descriptor = FetchDescriptor<UserSetting>()
        let existing = try? context.fetch(descriptor)
        if let first = existing?.first {
            settings = first
        } else {
            let newSettings = UserSetting()
            context.insert(newSettings)
            try? context.save()
            settings = newSettings
        }
    }

    func saveSettings(context: ModelContext) {
        try? context.save()
    }

    func requestNotifications() async {
        do {
            notificationAuthorized = try await container.notificationScheduler.requestAuthorization()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rescheduleNotifications(latitude: Double, longitude: Double) async {
        guard let settings else { return }
        do {
            let days = try await container.prayerTimesRepository.prayerTimes(
                from: Date(),
                days: 10,
                latitude: latitude,
                longitude: longitude,
                method: settings.calculationMethod,
                asrMethod: settings.asrMethod
            )
            let notifSettings = NotificationSettings(
                fajrEnabled: settings.fajrNotification,
                sunriseEnabled: settings.sunriseNotification,
                dhuhrEnabled: settings.dhuhrNotification,
                asrEnabled: settings.asrNotification,
                maghribEnabled: settings.maghribNotification,
                ishaEnabled: settings.ishaNotification,
                minutesBefore: settings.notificationMinutesBefore
            )
            try await container.notificationScheduler.scheduleRollingWindow(days: days, settings: notifSettings)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
