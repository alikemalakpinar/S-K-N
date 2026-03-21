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

    // Time-of-day greeting
    var greeting: String { Self.currentGreeting() }
    var greetingIcon: String { Self.currentGreetingIcon() }

    // Prayer progress — how far through today's prayers
    var prayedCount: Int {
        guard let log = todayLog else { return 0 }
        return [log.fajr, log.dhuhr, log.asr, log.maghrib, log.isha]
            .filter { $0 == .prayed }
            .count
    }

    private let container: DependencyContainer
    private static var cachedVerseOfDay: (date: Date, verse: VerseDTO, surahName: String)?
    private var hasGeocoded = false

    // ── Live Activity periodic update timer ────────────────
    private var liveActivityTimer: Timer?
    private var cachedLatitude: Double = 0
    private var cachedLongitude: Double = 0
    private var cachedMethod: String = "Turkey"
    private var cachedAsrMethod: String = "hanafi"

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Greeting Logic

    private static func currentGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 4..<7:   return L10n.Dashboard.greetingMorningEarly
        case 7..<12:  return L10n.Dashboard.greetingMorning
        case 12..<14: return L10n.Dashboard.greetingNoon
        case 14..<17: return L10n.Dashboard.greetingAfternoon
        case 17..<20: return L10n.Dashboard.greetingEvening
        case 20..<23: return L10n.Dashboard.greetingNight
        default:      return L10n.Dashboard.greetingLateNight
        }
    }

    private static func currentGreetingIcon() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<8:   return "sunrise.fill"
        case 8..<17:  return "sun.max.fill"
        case 17..<20: return "sunset.fill"
        default:      return "moon.stars.fill"
        }
    }

    // MARK: - Data Loading

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
        // Cache coordinates for periodic Live Activity updates
        cachedLatitude = latitude
        cachedLongitude = longitude
        cachedMethod = method
        cachedAsrMethod = asrMethod

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

                // Update Live Activity if running
                await updateLiveActivityIfNeeded(today: today, currentPrayer: next)
            } else {
                nextPrayerName = L10n.Prayer.isha
                nextPrayerTime = today.isha
            }
        } catch {
            errorMessage = UserFriendlyError.message(from: error)
        }
    }

    // MARK: - Live Activity Integration

    /// Start a new Live Activity with current prayer data.
    func startLiveActivity() {
        guard let time = nextPrayerTime else { return }
        do {
            try container.liveActivityManager.startLiveActivity(
                prayerName: nextPrayerName,
                prayerTime: time,
                followingPrayerName: nil,
                progress: 0.0,
                locationName: locationName
            )
            startPeriodicLiveActivityUpdates()
        } catch {
            #if DEBUG
            print("[LiveActivity] Start failed: \(error)")
            #endif
        }
    }

    /// End the running Live Activity.
    func stopLiveActivity() {
        stopPeriodicLiveActivityUpdates()
        Task { await container.liveActivityManager.endLiveActivity() }
    }

    /// Update the running Live Activity with current prayer & progress data.
    private func updateLiveActivityIfNeeded(
        today: PrayerDay,
        currentPrayer: (name: String, time: Date)
    ) async {
        guard container.liveActivityManager.isLiveActivityActive else { return }

        let allPrayers: [(String, Date)] = [
            (L10n.Prayer.fajr, today.fajr),
            (L10n.Prayer.sunrise, today.sunrise),
            (L10n.Prayer.dhuhr, today.dhuhr),
            (L10n.Prayer.asr, today.asr),
            (L10n.Prayer.maghrib, today.maghrib),
            (L10n.Prayer.isha, today.isha)
        ]

        let now = Date()
        var previousTime = Calendar.current.startOfDay(for: now)
        var followingName: String?

        for (i, prayer) in allPrayers.enumerated() {
            if prayer.0 == currentPrayer.name && prayer.1 == currentPrayer.time {
                if i > 0 { previousTime = allPrayers[i - 1].1 }
                if i + 1 < allPrayers.count { followingName = allPrayers[i + 1].0 }
                break
            }
        }

        let totalInterval = currentPrayer.time.timeIntervalSince(previousTime)
        let elapsed = now.timeIntervalSince(previousTime)
        let progress = totalInterval > 0 ? min(1.0, max(0.0, elapsed / totalInterval)) : 0.0

        await container.liveActivityManager.updateLiveActivity(
            prayerName: currentPrayer.name,
            prayerTime: currentPrayer.time,
            followingPrayerName: followingName,
            progress: progress
        )
    }

    // MARK: - Periodic Live Activity Updates

    /// Start a 60-second timer to keep the Live Activity progress bar fresh
    /// and handle prayer transitions.
    func startPeriodicLiveActivityUpdates() {
        stopPeriodicLiveActivityUpdates()
        liveActivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.loadNextPrayer(
                    latitude: self.cachedLatitude,
                    longitude: self.cachedLongitude,
                    method: self.cachedMethod,
                    asrMethod: self.cachedAsrMethod
                )
            }
        }
    }

    func stopPeriodicLiveActivityUpdates() {
        liveActivityTimer?.invalidate()
        liveActivityTimer = nil
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
