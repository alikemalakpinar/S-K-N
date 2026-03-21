import SwiftUI

/// A unified prayer time row component used across Prayer Times and Dashboard.
///
/// Shows prayer name with icon, time, and highlights the next prayer.
struct DSPrayerRow: View {
    let name: String
    let icon: String
    let time: Date
    let isNext: Bool

    init(_ name: String, icon: String, time: Date, isNext: Bool = false) {
        self.name = name
        self.icon = icon
        self.time = time
        self.isNext = isNext
    }

    var body: some View {
        HStack(spacing: DS.Space.md) {
            // Icon badge
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isNext ? DS.Color.accent : DS.Color.textSecondary)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.sm + 2, style: .continuous)
                        .fill(isNext ? DS.Color.accentSoft : DS.Color.hairline.opacity(0.5))
                )

            // Name + label
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(isNext ? DS.Typography.headline : DS.Typography.body)
                    .foregroundStyle(DS.Color.textPrimary)
                if isNext {
                    Text(L10n.Common.next)
                        .font(DS.Typography.micro)
                        .foregroundStyle(DS.Color.accent)
                        .tracking(2)
                }
            }

            Spacer()

            // Time
            Text(time, format: .dateTime.hour().minute())
                .font(isNext
                    ? .system(size: 28, weight: .bold, design: .rounded)
                    : .system(size: 17, weight: .medium, design: .monospaced))
                .foregroundStyle(isNext ? DS.Color.accent : DS.Color.textSecondary)
                .monospacedDigit()
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.vertical, isNext ? DS.Space.lg : DS.Space.md)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(isNext ? DS.Color.cardElevated : .clear)
                .shadow(color: isNext ? .black.opacity(0.04) : .clear, radius: 8, y: 2)
        )
    }

    /// Maps a prayer name to its SF Symbol icon.
    static func icon(for prayer: String) -> String {
        switch prayer {
        case L10n.Prayer.fajr: "sun.horizon"
        case L10n.Prayer.sunrise: "sunrise"
        case L10n.Prayer.dhuhr: "sun.max"
        case L10n.Prayer.asr: "sun.min"
        case L10n.Prayer.maghrib: "sunset"
        case L10n.Prayer.isha: "moon.stars"
        default: "clock"
        }
    }
}

// MARK: - Preview

#Preview("DSPrayerRow") {
    VStack(spacing: 0) {
        DSPrayerRow("Sabah", icon: "sun.horizon", time: Date(), isNext: false)
        DSPrayerRow("Öğle", icon: "sun.max", time: Date(), isNext: true)
        DSPrayerRow("İkindi", icon: "sun.min", time: Date(), isNext: false)
        DSPrayerRow("Akşam", icon: "sunset", time: Date(), isNext: false)
        DSPrayerRow("Yatsı", icon: "moon.stars", time: Date(), isNext: false)
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
