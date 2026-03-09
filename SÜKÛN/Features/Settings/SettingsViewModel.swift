import Foundation
import SwiftData
import CoreLocation

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
        do {
            let descriptor = FetchDescriptor<UserSetting>()
            let existing = try context.fetch(descriptor)
            if let first = existing.first {
                settings = first
            } else {
                let newSettings = UserSetting()
                context.insert(newSettings)
                try context.save()
                settings = newSettings
            }
        } catch {
            errorMessage = UserFriendlyError.message(from: error)
        }
    }

    func saveSettings(context: ModelContext) {
        do {
            try context.save()
        } catch {
            errorMessage = UserFriendlyError.message(from: error)
        }
    }

    /// Save settings and reschedule notifications (for prayer-affecting changes)
    func saveAndReschedule(context: ModelContext) {
        saveSettings(context: context)
        Task {
            do {
                let coords = try await container.locationService.currentCoordinates()
                await rescheduleNotifications(latitude: coords.latitude, longitude: coords.longitude)
            } catch {
                // Location unavailable — notifications stay as-is
                #if DEBUG
                print("[Settings] Reschedule skipped — location unavailable: \(error)")
                #endif
            }
        }
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
