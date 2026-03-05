import Foundation

protocol PrayerTimeServiceProtocol: Sendable {
    func computeAndCache(latitude: Double, longitude: Double, method: String, asrMethod: String) async throws -> [PrayerDay]
    func loadCached() async -> [PrayerDay]?
    func todayPrayerTimes(latitude: Double, longitude: Double, method: String, asrMethod: String) async throws -> PrayerDay
    func nextPrayer(from times: PrayerDay, after: Date) -> (name: String, time: Date)?
}

final class PrayerTimeService: PrayerTimeServiceProtocol, Sendable {
    private let repository: PrayerTimesRepository
    private let cacheURL: URL

    init(repository: PrayerTimesRepository) {
        self.repository = repository

        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("applicationSupportDirectory unavailable — system configuration error")
        }
        let dir = appSupport.appendingPathComponent("Sukun", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.cacheURL = dir.appendingPathComponent("PrayerTimesCache.json")
    }

    func computeAndCache(latitude: Double, longitude: Double, method: String, asrMethod: String) async throws -> [PrayerDay] {
        let today = Calendar.current.startOfDay(for: Date())
        let days = try await repository.prayerTimes(from: today, days: 30, latitude: latitude, longitude: longitude, method: method, asrMethod: asrMethod)

        // Cache to disk
        let entries = days.map { CachedPrayerDay(from: $0) }
        let data = try JSONEncoder().encode(entries)
        try data.write(to: cacheURL, options: .atomic)

        return days
    }

    func loadCached() async -> [PrayerDay]? {
        guard let data = try? Data(contentsOf: cacheURL),
              let entries = try? JSONDecoder().decode([CachedPrayerDay].self, from: data) else {
            return nil
        }
        return entries.map { $0.toPrayerDay() }
    }

    func todayPrayerTimes(latitude: Double, longitude: Double, method: String, asrMethod: String) async throws -> PrayerDay {
        try await repository.prayerTimes(for: Date(), latitude: latitude, longitude: longitude, method: method, asrMethod: asrMethod)
    }

    func nextPrayer(from times: PrayerDay, after now: Date) -> (name: String, time: Date)? {
        let prayers: [(String, Date)] = [
            ("Sabah", times.fajr),
            ("Güneş", times.sunrise),
            ("Öğle", times.dhuhr),
            ("İkindi", times.asr),
            ("Akşam", times.maghrib),
            ("Yatsı", times.isha)
        ]
        return prayers.first { $0.1 > now }
    }
}

// MARK: - Cache Model

private struct CachedPrayerDay: Codable {
    let date: Date
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date

    init(from day: PrayerDay) {
        self.date = day.date
        self.fajr = day.fajr
        self.sunrise = day.sunrise
        self.dhuhr = day.dhuhr
        self.asr = day.asr
        self.maghrib = day.maghrib
        self.isha = day.isha
    }

    func toPrayerDay() -> PrayerDay {
        PrayerDay(date: date, fajr: fajr, sunrise: sunrise, dhuhr: dhuhr, asr: asr, maghrib: maghrib, isha: isha)
    }
}
