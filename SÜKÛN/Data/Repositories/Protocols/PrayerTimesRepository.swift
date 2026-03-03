import Foundation

struct PrayerDay: Sendable {
    let date: Date
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
}

protocol PrayerTimesRepository: Sendable {
    func prayerTimes(for date: Date, latitude: Double, longitude: Double, method: String, asrMethod: String) async throws -> PrayerDay
    func prayerTimes(from startDate: Date, days: Int, latitude: Double, longitude: Double, method: String, asrMethod: String) async throws -> [PrayerDay]
}
