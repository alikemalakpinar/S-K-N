import Foundation
import SwiftData

@Model
final class PrayerLog {
    var date: Date = Date()
    var fajr: PrayerStatus = .notLogged
    var dhuhr: PrayerStatus = .notLogged
    var asr: PrayerStatus = .notLogged
    var maghrib: PrayerStatus = .notLogged
    var isha: PrayerStatus = .notLogged

    init(date: Date) {
        self.date = Calendar.current.startOfDay(for: date)
    }
}

enum PrayerStatus: String, Codable {
    case notLogged
    case prayed
    case missed
    case late
}
