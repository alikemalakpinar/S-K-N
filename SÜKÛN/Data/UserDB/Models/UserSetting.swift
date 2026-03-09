import Foundation
import SwiftData

@Model
final class UserSetting {
    @Attribute(.unique) var id: String = "default"

    // Calculation method (e.g., "Turkey", "MuslimWorldLeague", "Egyptian", etc.)
    var calculationMethod: String = "Turkey"

    // Asr juristic method: "standard" (Shafi/Maliki/Hanbali) or "hanafi"
    var asrMethod: String = "hanafi"

    // Manual offsets in minutes for each prayer
    var fajrOffset: Int = 0
    var sunriseOffset: Int = 0
    var dhuhrOffset: Int = 0
    var asrOffset: Int = 0
    var maghribOffset: Int = 0
    var ishaOffset: Int = 0

    // Appearance
    var theme: String = "system" // "system", "light", "dark"
    var fontScale: Double = 1.0

    // Notification preferences
    var fajrNotification: Bool = true
    var sunriseNotification: Bool = false
    var dhuhrNotification: Bool = true
    var asrNotification: Bool = true
    var maghribNotification: Bool = true
    var ishaNotification: Bool = true
    var notificationMinutesBefore: Int = 0

    // Quran reading preferences
    var showTransliteration: Bool = false
    var showTranslation: Bool = true
    var dailyPageGoal: Int = 5
    var quranReadingMode: String = "arabic"
    var quranReadingTheme: String = "Açık"   // ReadingTheme.rawValue
    var quranFontScale: Double = 1.0

    // Live Activity
    var liveActivityEnabled: Bool = false

    init() {}
}
