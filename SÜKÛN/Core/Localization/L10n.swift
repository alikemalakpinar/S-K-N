import Foundation

// MARK: - L10n (Localization Namespace)
// Type-safe access to all user-visible strings.
// Backed by Localizable.strings for future multi-language support.

enum L10n {

    // MARK: - Tab Bar

    enum Tab {
        static let home = String(localized: "tab.home")
        static let prayer = String(localized: "tab.prayer")
        static let quran = String(localized: "tab.quran")
        static let qibla = String(localized: "tab.qibla")
        static let dhikr = String(localized: "tab.dhikr")
    }

    // MARK: - Common Prayer Names

    enum Prayer {
        static let fajr = String(localized: "prayer.fajr")
        static let sunrise = String(localized: "prayer.sunrise")
        static let dhuhr = String(localized: "prayer.dhuhr")
        static let asr = String(localized: "prayer.asr")
        static let maghrib = String(localized: "prayer.maghrib")
        static let isha = String(localized: "prayer.isha")
    }

    // MARK: - Common

    enum Common {
        static let hour = String(localized: "common.hour")
        static let minute = String(localized: "common.minute")
        static let second = String(localized: "common.second")
        static let day = String(localized: "common.day")
        static let namaz = String(localized: "common.namaz")
        static let next = String(localized: "common.next")
        static let loading = String(localized: "common.loading")
        static let minuteAbbrev = String(localized: "common.minuteAbbrev")

        static func page(_ n: Int) -> String { "Sayfa \(n)" }
        static func ayetCount(_ n: Int) -> String { "\(n) ayet" }
        static func pagesProgress(_ read: Int, _ goal: Int) -> String { "\(read)/\(goal) sayfa" }
    }

    // MARK: - Dashboard

    enum Dashboard {
        static let title = String(localized: "dashboard.title")
        static let locationLoading = String(localized: "dashboard.locationLoading")
        static let todayPrayers = String(localized: "dashboard.todayPrayers")
        static let whereYouLeft = String(localized: "dashboard.whereYouLeft")
        static let today = String(localized: "dashboard.today")
        static let continuity = String(localized: "dashboard.continuity")
        static let verseOfDay = String(localized: "dashboard.verseOfDay")
        static let guide = String(localized: "dashboard.guide")
        static let guideSubtitle = String(localized: "dashboard.guideSubtitle")
        static let kaza = String(localized: "dashboard.kaza")
        static let kazaSubtitle = String(localized: "dashboard.kazaSubtitle")
        static let duas = String(localized: "dashboard.duas")
        static let duasSubtitle = String(localized: "dashboard.duasSubtitle")
        static let tracker = String(localized: "dashboard.tracker")
        static let trackerSubtitle = String(localized: "dashboard.trackerSubtitle")

        // Greetings
        static let greetingMorningEarly = String(localized: "dashboard.greeting.morningEarly")
        static let greetingMorning = String(localized: "dashboard.greeting.morning")
        static let greetingNoon = String(localized: "dashboard.greeting.noon")
        static let greetingAfternoon = String(localized: "dashboard.greeting.afternoon")
        static let greetingEvening = String(localized: "dashboard.greeting.evening")
        static let greetingNight = String(localized: "dashboard.greeting.night")
        static let greetingLateNight = String(localized: "dashboard.greeting.lateNight")

        static func prayerAccessibility(name: String, isPrayed: Bool) -> String {
            "\(name) namazı, \(isPrayed ? "kılındı" : "kılınmadı")"
        }
    }

    // MARK: - Prayer Times

    enum PrayerTimes {
        static let title = String(localized: "prayerTimes.title")
        static let todaySection = String(localized: "prayerTimes.today")
        static let upcoming = String(localized: "prayerTimes.upcoming")
        static let noData = String(localized: "prayerTimes.noData")
        static let locationRequired = String(localized: "prayerTimes.locationRequired")
        static let hijriDate = String(localized: "prayerTimes.hijriDate")
        static let remaining = String(localized: "prayerTimes.remaining")
    }

    // MARK: - Quran

    enum Quran {
        static let title = String(localized: "quran.title")
        static let searchPrompt = String(localized: "quran.searchPrompt")
        static let noResults = String(localized: "quran.noResults")
        static let dbMissing = String(localized: "quran.dbMissing")
        static let readingArabic = String(localized: "quran.readingArabic")
        static let readingTransliteration = String(localized: "quran.readingTransliteration")
        static let readingTranslation = String(localized: "quran.readingTranslation")
        static let readingAll = String(localized: "quran.readingAll")
        static let readingSettings = String(localized: "quran.readingSettings")
        static let selectPage = String(localized: "quran.selectPage")
        static let theme = String(localized: "quran.theme")
        static let fontSize = String(localized: "quran.fontSize")
        static let transliteration = String(localized: "quran.transliteration")
        static let bismillahTranslation = String(localized: "quran.bismillahTranslation")
        static let tapToDetail = String(localized: "quran.tapToDetail")

        static func noResultsFor(_ query: String) -> String {
            "\"\(query)\" için ayet bulunamadı."
        }
        static func juz(_ n: Int) -> String { "Cüz \(n)" }
        static func verseAccessibility(_ n: Int, translation: String) -> String {
            "Ayet \(n). \(translation)"
        }
    }

    // MARK: - Qibla

    enum Qibla {
        static let title = String(localized: "qibla.title")
        static let direction = String(localized: "qibla.direction")
        static let lockedOn = String(localized: "qibla.lockedOn")
        static let locationLoading = String(localized: "qibla.locationLoading")
        static let locationFailed = String(localized: "qibla.locationFailed")
        static let calibrationNeeded = String(localized: "qibla.calibrationNeeded")
        static let calibrationTitle = String(localized: "qibla.calibrationTitle")
        static let right = String(localized: "qibla.right")
        static let left = String(localized: "qibla.left")
    }

    // MARK: - Dhikr

    enum Dhikr {
        static let tapOrSwipe = String(localized: "dhikr.tapOrSwipe")
        static let selectDhikr = String(localized: "dhikr.selectDhikr")
        static let history = String(localized: "dhikr.history")
        static let reset = String(localized: "dhikr.reset")
        static let tourComplete = String(localized: "dhikr.tourComplete")
        static let noHistory = String(localized: "dhikr.noHistoryTitle")
        static let noHistoryMessage = String(localized: "dhikr.noHistoryMessage")
        static let todayTotal = String(localized: "dhikr.todayTotal")

        // Preset descriptions
        static let subhanallahDesc = String(localized: "dhikr.subhanallahDesc")
        static let alhamdulillahDesc = String(localized: "dhikr.alhamdulillahDesc")
        static let allahuAkbarDesc = String(localized: "dhikr.allahuAkbarDesc")

        static func countAccessibility(_ current: Int, _ target: Int, _ tours: Int) -> String {
            "\(current) / \(target) sayım, \(tours) tur"
        }
    }

    // MARK: - Kaza

    enum Kaza {
        static let title = String(localized: "kaza.title")
        static let totalKaza = String(localized: "kaza.totalKaza")
        static let infoTitle = String(localized: "kaza.infoTitle")
        static let infoMessage = String(localized: "kaza.infoMessage")
        static let loadFailed = String(localized: "kaza.loadFailed")
    }

    // MARK: - Settings

    enum Settings {
        static let title = String(localized: "settings.title")
        static let calculationMethod = String(localized: "settings.calculationMethod")
        static let method = String(localized: "settings.method")
        static let asrSchool = String(localized: "settings.asrSchool")
        static let shafii = String(localized: "settings.shafii")
        static let hanafi = String(localized: "settings.hanafi")
        static let manualOffsets = String(localized: "settings.manualOffsets")
        static let notifications = String(localized: "settings.notifications")
        static let alertBefore = String(localized: "settings.alertBefore")
        static let liveActivity = String(localized: "settings.liveActivity")
        static let requestNotification = String(localized: "settings.requestNotification")
        static let appearance = String(localized: "settings.appearance")
        static let themeLabel = String(localized: "settings.themeLabel")
        static let themeSystem = String(localized: "settings.themeSystem")
        static let themeLight = String(localized: "settings.themeLight")
        static let themeDark = String(localized: "settings.themeDark")
        static let fontSizeLabel = String(localized: "settings.fontSizeLabel")
        static let other = String(localized: "settings.other")
        static let about = String(localized: "settings.about")
        static let prayerSettings = String(localized: "settings.prayerSettings")
        static let prayerSettingsSubtitle = String(localized: "settings.prayerSettingsSubtitle")
        static let notificationsSubtitle = String(localized: "settings.notificationsSubtitle")
        static let appearanceSubtitle = String(localized: "settings.appearanceSubtitle")
        static let version = String(localized: "settings.version")
    }

    // MARK: - About

    enum About {
        static let title = String(localized: "about.title")
        static let quranTextTitle = String(localized: "about.quranTextTitle")
        static let quranDataInfo = String(localized: "about.quranDataInfo")
        static let translationTitle = String(localized: "about.translationTitle")
        static let translationInfo = String(localized: "about.translationInfo")
        static let openSourceTitle = String(localized: "about.openSourceTitle")
        static let grdbDetail = String(localized: "about.grdbDetail")
        static let adhanDetail = String(localized: "about.adhanDetail")
    }

    // MARK: - Rehber

    enum Rehber {
        static let title = String(localized: "rehber.title")
        static let lettersTitle = String(localized: "rehber.lettersTitle")
        static let lettersSubtitle = String(localized: "rehber.lettersSubtitle")
        static let abdestTitle = String(localized: "rehber.abdestTitle")
        static let abdestSubtitle = String(localized: "rehber.abdestSubtitle")
        static let namazTitle = String(localized: "rehber.namazTitle")
        static let namazSubtitle = String(localized: "rehber.namazSubtitle")
        static let abdestNavTitle = String(localized: "rehber.abdestNavTitle")
        static let namazNavTitle = String(localized: "rehber.namazNavTitle")
        static let readingMode = String(localized: "rehber.readingMode")
        static let initialForm = String(localized: "rehber.initialForm")
    }

    // MARK: - Duas

    enum Duas {
        static let title = String(localized: "duas.title")
        static let searchPrompt = String(localized: "duas.searchPrompt")
        static let dbMissing = String(localized: "duas.dbMissing")
        static let searchHint = String(localized: "duas.searchHint")
        static let categories = String(localized: "duas.categories")
        static let allDuas = String(localized: "duas.allDuas")
        static let noResults = String(localized: "duas.noResults")

        static func noResultsFor(_ query: String) -> String {
            "\"\(query)\" için dua bulunamadı."
        }
    }

    // MARK: - Profile

    enum Profile {
        static let title = String(localized: "profile.title")
        static let myJourney = String(localized: "profile.myJourney")
        static let hatimProgress = String(localized: "profile.hatimProgress")
        static let readingStreak = String(localized: "profile.readingStreak")
        static let days = String(localized: "profile.days")
        static let pagesRead = String(localized: "profile.pagesRead")
        static let totalDhikr = String(localized: "profile.totalDhikr")
        static let todayPrayers = String(localized: "profile.todayPrayers")
        static let quickLinks = String(localized: "profile.quickLinks")
        static let settings = String(localized: "profile.settings")
        static let tracker = String(localized: "profile.tracker")
        static let bookmarks = String(localized: "profile.bookmarks")
        static let noStreak = String(localized: "profile.noStreak")
        static let startReading = String(localized: "profile.startReading")
    }

    // MARK: - Journey

    enum Journey {
        static let title = String(localized: "journey.title")
        static let pagesReadTitle = String(localized: "journey.pagesReadTitle")
        static let streak = String(localized: "journey.streak")
        static let dhikrTotal = String(localized: "journey.dhikrTotal")
        static let prayersWeek = String(localized: "journey.prayersWeek")
        static let hatimJourney = String(localized: "journey.hatimJourney")
        static let pagesComplete = String(localized: "journey.pagesComplete")
        static let pagesRemaining = String(localized: "journey.pagesRemaining")
        static let juzComplete = String(localized: "journey.juzComplete")
        static let weeklyActivity = String(localized: "journey.weeklyActivity")
        static let legendPrayer = String(localized: "journey.legendPrayer")
        static let legendReading = String(localized: "journey.legendReading")
        static let legendDhikr = String(localized: "journey.legendDhikr")
        static let milestones = String(localized: "journey.milestones")
        static let milestoneFirstJuz = String(localized: "journey.milestoneFirstJuz")
        static let milestoneQuarterHatim = String(localized: "journey.milestoneQuarterHatim")
        static let milestoneHalfHatim = String(localized: "journey.milestoneHalfHatim")
        static let milestoneWeekStreak = String(localized: "journey.milestoneWeekStreak")
        static let milestoneMonthStreak = String(localized: "journey.milestoneMonthStreak")
        static let milestoneDhikr1000 = String(localized: "journey.milestoneDhikr1000")

        static func ofTotal(_ total: Int) -> String { "/ \(total) sayfa" }
        static func milestonePagesOf(_ current: Int, _ total: Int) -> String { "\(current) / \(total) sayfa" }
        static func milestoneStreakDays(_ days: Int) -> String { "\(days) gün seri" }
        static func milestoneDhikrCount(_ count: Int) -> String { "\(count)+ zikir" }
    }

    // MARK: - Bookmarks

    enum Bookmarks {
        static let title = String(localized: "bookmarks.title")
        static let emptyTitle = String(localized: "bookmarks.emptyTitle")
        static let emptyMessage = String(localized: "bookmarks.emptyMessage")
        static let verse = String(localized: "bookmarks.verse")
        static let dua = String(localized: "bookmarks.dua")
        static let page = String(localized: "bookmarks.page")
    }

    // MARK: - Tracker

    enum Tracker {
        static let title = String(localized: "tracker.title")
        static let dhikr = String(localized: "tracker.dhikr")
        static let minutesReading = String(localized: "tracker.minutesReading")
        static let activeDay = String(localized: "tracker.activeDay")
        static let weeklyDhikr = String(localized: "tracker.weeklyDhikr")
        static let noWeeklyDhikr = String(localized: "tracker.noWeeklyDhikr")
        static let reading = String(localized: "tracker.reading")
        static let noReadingLog = String(localized: "tracker.noReadingLog")
        static let dhikrSessions = String(localized: "tracker.dhikrSessions")
        static let noDhikrSession = String(localized: "tracker.noDhikrSession")

        static let dayMon = String(localized: "tracker.dayMon")
        static let dayTue = String(localized: "tracker.dayTue")
        static let dayWed = String(localized: "tracker.dayWed")
        static let dayThu = String(localized: "tracker.dayThu")
        static let dayFri = String(localized: "tracker.dayFri")
        static let daySat = String(localized: "tracker.daySat")
        static let daySun = String(localized: "tracker.daySun")
        static var weekDays: [String] { [dayMon, dayTue, dayWed, dayThu, dayFri, daySat, daySun] }

        static func logCount(_ n: Int) -> String { "\(n) kayıt" }
        static func sessionCount(_ n: Int) -> String { "\(n) seans" }
    }

    // MARK: - Onboarding

    enum Onboarding {
        static let appName = String(localized: "onboarding.appName")
        static let subtitle = String(localized: "onboarding.subtitle")
        static let locationTitle = String(localized: "onboarding.locationTitle")
        static let locationBody = String(localized: "onboarding.locationBody")
        static let locationGranted = String(localized: "onboarding.locationGranted")
        static let notificationTitle = String(localized: "onboarding.notificationTitle")
        static let notificationBody = String(localized: "onboarding.notificationBody")
        static let notificationGranted = String(localized: "onboarding.notificationGranted")
        static let readyTitle = String(localized: "onboarding.readyTitle")
        static let readyBody = String(localized: "onboarding.readyBody")
        static let start = String(localized: "onboarding.start")
        static let continueBtn = String(localized: "onboarding.continue")
        static let grantLocation = String(localized: "onboarding.grantLocation")
        static let enableNotifications = String(localized: "onboarding.enableNotifications")
        static let enterApp = String(localized: "onboarding.enterApp")
    }

    // MARK: - Errors

    enum Error {
        static let locationDenied = String(localized: "error.locationDenied")
        static let databaseFailed = String(localized: "error.databaseFailed")
        static let noInternet = String(localized: "error.noInternet")
        static let notFound = String(localized: "error.notFound")
        static let prayerCalcFailed = String(localized: "error.prayerCalcFailed")
        static let decodingFailed = String(localized: "error.decodingFailed")
        static let genericError = String(localized: "error.generic")
        static let compassUnavailable = String(localized: "error.compassUnavailable")
        static let abdestLoadFailed = String(localized: "error.abdestLoadFailed")
        static let namazLoadFailed = String(localized: "error.namazLoadFailed")
        static let elifbaLoadFailed = String(localized: "error.elifbaLoadFailed")
        static let liveActivityDisabled = String(localized: "error.liveActivityDisabled")
    }

    // MARK: - State Views

    enum State {
        static let defaultLoading = String(localized: "state.defaultLoading")
        static let defaultError = String(localized: "state.defaultError")
    }

    // MARK: - Revelation Type

    static func revelationType(_ type: String) -> String {
        type == "Meccan" ? "Mekki" : "Medeni"
    }
}
