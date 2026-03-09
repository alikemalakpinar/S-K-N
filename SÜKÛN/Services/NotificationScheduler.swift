import Foundation
import UserNotifications

protocol NotificationSchedulerProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleRollingWindow(days: [PrayerDay], settings: NotificationSettings) async throws
    func clearAllScheduledNotifications() async
}

struct NotificationSettings: Sendable {
    let fajrEnabled: Bool
    let sunriseEnabled: Bool
    let dhuhrEnabled: Bool
    let asrEnabled: Bool
    let maghribEnabled: Bool
    let ishaEnabled: Bool
    let minutesBefore: Int
}

final class NotificationScheduler: NotificationSchedulerProtocol, Sendable {
    private let center = UNUserNotificationCenter.current()
    private let maxDays = 10
    // iOS allows max 64 pending notifications; 6 prayers x 10 days = 60, leaving headroom
    private let prayersPerDay = 6

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleRollingWindow(days: [PrayerDay], settings: NotificationSettings) async throws {
        // Clear existing prayer notifications first
        await clearAllScheduledNotifications()

        let windowDays = Array(days.prefix(maxDays))
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        for day in windowDays {
            let prayers = enabledPrayers(for: day, settings: settings)

            for (name, time) in prayers {
                let adjustedTime = Calendar.current.date(byAdding: .minute, value: -settings.minutesBefore, to: time) ?? time
                guard adjustedTime > Date() else { continue }

                let content = UNMutableNotificationContent()
                content.title = "Sukun"
                content.body = "\(name) - \(formatter.string(from: time))"
                content.sound = .default
                content.categoryIdentifier = "PRAYER_REMINDER"

                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: adjustedTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                let dateString = ISO8601DateFormatter().string(from: day.date)
                let id = "prayer_\(name.lowercased())_\(dateString)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                try await center.add(request)
            }
        }
    }

    func clearAllScheduledNotifications() async {
        let pending = await center.pendingNotificationRequests()
        let prayerIds = pending.filter { $0.identifier.hasPrefix("prayer_") }.map(\.identifier)
        center.removePendingNotificationRequests(withIdentifiers: prayerIds)
    }

    // MARK: - Helpers

    private func enabledPrayers(for day: PrayerDay, settings: NotificationSettings) -> [(String, Date)] {
        var prayers: [(String, Date)] = []
        if settings.fajrEnabled    { prayers.append(("Sabah", day.fajr)) }
        if settings.sunriseEnabled { prayers.append(("Güneş", day.sunrise)) }
        if settings.dhuhrEnabled   { prayers.append(("Öğle", day.dhuhr)) }
        if settings.asrEnabled     { prayers.append(("İkindi", day.asr)) }
        if settings.maghribEnabled { prayers.append(("Akşam", day.maghrib)) }
        if settings.ishaEnabled    { prayers.append(("Yatsı", day.isha)) }
        return prayers
    }
}
