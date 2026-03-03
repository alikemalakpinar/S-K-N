import Foundation
import SwiftData

@Model
final class PrayerLog {
    var date: Date = Date()
    var fajr: PrayerStatus = PrayerStatus.notLogged
    var dhuhr: PrayerStatus = PrayerStatus.notLogged
    var asr: PrayerStatus = PrayerStatus.notLogged
    var maghrib: PrayerStatus = PrayerStatus.notLogged
    var isha: PrayerStatus = PrayerStatus.notLogged

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
