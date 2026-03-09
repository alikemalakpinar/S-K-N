import Foundation
import SwiftData
import CoreLocation

@Observable
final class DashboardViewModel {
    var nextPrayerName: String = "--"
    var nextPrayerTime: Date?
    var todayLog: PrayerLog?
    var isLoading = false
    var errorMessage: String?
    var locationName: String = ""

    // Reading progress
    var lastReadPosition: LastReadPosition?
    var verseOfTheDay: VerseDTO?
    var verseOfTheDaySurahName: String = ""
    var pagesReadToday: Int = 0
    var dailyPageGoal: Int = 5
    var totalUniquePages: Int = 0
    var readingStreakDays: Int = 0
    var quranProgressPercent: Double = 0.0
    var isDashboardLoaded = false

    private let container: DependencyContainer
    private static var cachedVerseOfDay: (date: Date, verse: VerseDTO, surahName: String)?
    private var hasGeocoded = false

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadTodayData(context: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        // Load today's prayer log
        do {
            todayLog = try container.userActivityRepository.getOrCreatePrayerLog(for: Date(), context: context)
        } catch {
            errorMessage = UserFriendlyError.message(from: error)
        }

        // Load reading progress
        do {
            lastReadPosition = try container.userActivityRepository.getLastReadPosition(context: context)
            pagesReadToday = try container.userActivityRepository.pagesReadToday(context: context)
            totalUniquePages = try container.userActivityRepository.totalUniquePagesRead(context: context)
            readingStreakDays = try container.userActivityRepository.readingStreakDays(context: context)
            quranProgressPercent = Double(totalUniquePages) / 604.0

            let descriptor = FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" })
            if let settings = try? context.fetch(descriptor).first {
                dailyPageGoal = settings.dailyPageGoal
            }
        } catch {
            #if DEBUG
            print("[Dashboard] Reading progress load failed: \(error)")
            #endif
        }

        // Load verse of the day (cached per day)
        let today = Calendar.current.startOfDay(for: Date())
        if let cached = Self.cachedVerseOfDay, Calendar.current.isDate(cached.date, inSameDayAs: today) {
            verseOfTheDay = cached.verse
            verseOfTheDaySurahName = cached.surahName
        } else {
            do {
                let verse = try await container.quranRepository.randomVerse()
                let surahs = try await container.quranRepository.allSurahs()
                let surahName = surahs.first(where: { $0.id == verse.surahId })?.nameTurkish ?? ""
                verseOfTheDay = verse
                verseOfTheDaySurahName = surahName
                Self.cachedVerseOfDay = (date: today, verse: verse, surahName: surahName)
            } catch {
                #if DEBUG
                print("[Dashboard] Verse of the day failed: \(error)")
                #endif
            }
        }

        isDashboardLoaded = true
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

                try? container.widgetDataService.writeNextPrayerData(name: next.name, time: next.time)
            } else {
                nextPrayerName = "Yatsı"
                nextPrayerTime = today.isha
            }
        } catch {
            errorMessage = UserFriendlyError.message(from: error)
        }
    }

    // MARK: - Reverse Geocoding

    func loadLocationName(latitude: Double, longitude: Double) {
        guard !hasGeocoded else { return }
        hasGeocoded = true

        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self, let placemark = placemarks?.first else { return }
            Task { @MainActor in
                let city = placemark.locality ?? placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""
                if !city.isEmpty && !country.isEmpty {
                    self.locationName = "\(city), \(country)"
                } else if !country.isEmpty {
                    self.locationName = country
                }
            }
        }
    }
}
