import SwiftUI
import SwiftData
import CoreLocation

struct PrayerTimesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PrayerTimesViewModel
    @State private var appeared = false
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        _viewModel = State(initialValue: PrayerTimesViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    DSSkeletonGroup(rows: 6)
                } else if let today = viewModel.todayTimes {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: DS.Space.x2) {
                            // Hijri date + Sun arc
                            headerSection(today)
                                .dsAppear(loaded: appeared, index: 0)

                            // Today's prayer times
                            todaySection(today)
                                .dsAppear(loaded: appeared, index: 1)

                            // Upcoming days
                            if viewModel.upcomingDays.count > 1 {
                                upcomingSection
                                    .dsAppear(loaded: appeared, index: 2)
                            }
                        }
                        .padding(.horizontal, DS.Space.lg)
                        .padding(.bottom, DS.Space.x4 + 60)
                    }
                    .onAppear {
                        withAnimation(DS.Motion.slowReveal) { appeared = true }
                    }
                } else if let error = viewModel.errorMessage {
                    SKNErrorState(
                        icon: "exclamationmark.triangle",
                        message: error
                    )
                } else {
                    SKNEmptyState(
                        icon: "clock",
                        title: L10n.PrayerTimes.noData,
                        message: L10n.PrayerTimes.locationRequired
                    )
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle(L10n.PrayerTimes.title)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                let descriptor = FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" })
                let settings = (try? modelContext.fetch(descriptor))?.first
                let method = settings?.calculationMethod ?? "Turkey"
                let asr = settings?.asrMethod ?? "hanafi"

                // Try cached prayer times first (no location needed)
                if let cached = await container.prayerTimeService.loadCached() {
                    viewModel.todayTimes = cached.first
                    viewModel.upcomingDays = cached
                }

                // Then try fresh location in background (non-blocking)
                do {
                    let coords = try await container.locationService.currentCoordinates()
                    await viewModel.loadPrayerTimes(
                        latitude: coords.latitude,
                        longitude: coords.longitude,
                        method: method,
                        asrMethod: asr
                    )
                } catch {
                    if viewModel.todayTimes == nil {
                        viewModel.errorMessage = UserFriendlyError.message(from: error)
                    }
                }
            }
        }
    }

    // MARK: - Header (Hijri Date + Sun Arc)

    private func headerSection(_ day: PrayerDay) -> some View {
        DSCard {
            VStack(spacing: DS.Space.lg) {
                // Hijri date
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(hijriDateString())
                            .font(DS.Typography.headline)
                            .foregroundStyle(DS.Color.textPrimary)
                        Text(gregorianDateString())
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    Spacer()

                    // Remaining time to next prayer
                    if let (name, remaining) = nextPrayerInfo(day) {
                        VStack(alignment: .trailing, spacing: 3) {
                            HStack(spacing: DS.Space.xs) {
                                Circle()
                                    .fill(DS.Color.accent)
                                    .frame(width: 6, height: 6)
                                    .symbolEffect(.pulse, options: .repeating.speed(0.5))
                                Text(name)
                                    .font(DS.Typography.micro)
                                    .foregroundStyle(DS.Color.accent)
                                    .tracking(1.5)
                            }
                            Text(remaining)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(DS.Color.textPrimary)
                                .monospacedDigit()
                                .contentTransition(.numericText())
                        }
                    }
                }

                // Sun arc
                SunArcView(
                    sunrise: day.sunrise,
                    sunset: day.maghrib,
                    prayerMarkers: prayerMarkers(for: day)
                )
            }
        }
    }

    // MARK: - Today

    private func todaySection(_ day: PrayerDay) -> some View {
        VStack(spacing: DS.Space.sm) {
            DSSectionHeader(L10n.PrayerTimes.todaySection, serif: true)

            VStack(spacing: 0) {
                prayerRow(L10n.Prayer.fajr, time: day.fajr, day: day)
                Hairline().padding(.leading, 52)
                prayerRow(L10n.Prayer.sunrise, time: day.sunrise, day: day, isSunrise: true)
                Hairline().padding(.leading, 52)
                prayerRow(L10n.Prayer.dhuhr, time: day.dhuhr, day: day)
                Hairline().padding(.leading, 52)
                prayerRow(L10n.Prayer.asr, time: day.asr, day: day)
                Hairline().padding(.leading, 52)
                prayerRow(L10n.Prayer.maghrib, time: day.maghrib, day: day)
                Hairline().padding(.leading, 52)
                prayerRow(L10n.Prayer.isha, time: day.isha, day: day)
            }
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(DS.Color.cardElevated)
                    .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
            )
        }
    }

    private func prayerRow(_ name: String, time: Date, day: PrayerDay, isSunrise: Bool = false) -> some View {
        let next = isSunrise ? false : isNext(name, day)
        return DSPrayerRow(
            name,
            icon: DSPrayerRow.icon(for: name),
            time: time,
            isNext: next
        )
    }

    private func isNext(_ name: String, _ day: PrayerDay) -> Bool {
        let now = Date()
        let pairs: [(String, Date)] = [
            (L10n.Prayer.fajr, day.fajr), (L10n.Prayer.dhuhr, day.dhuhr),
            (L10n.Prayer.asr, day.asr), (L10n.Prayer.maghrib, day.maghrib), (L10n.Prayer.isha, day.isha)
        ]
        for (n, t) in pairs {
            if t > now { return n == name }
        }
        return false
    }

    // MARK: - Upcoming

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            DSSectionHeader(L10n.PrayerTimes.upcoming, serif: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Space.md) {
                    ForEach(Array(viewModel.upcomingDays.dropFirst().enumerated()), id: \.element.date) { index, day in
                        UpcomingDayCard(day: day)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: DS.Space.md)
                            .dsAppear(loaded: appeared, index: index + 3)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }

    // MARK: - Helpers

    private func hijriDateString() -> String {
        let hijri = Calendar(identifier: .islamicUmmAlQura)
        let formatter = DateFormatter()
        formatter.calendar = hijri
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "tr")
        return formatter.string(from: Date())
    }

    private func gregorianDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr")
        return formatter.string(from: Date())
    }

    private func nextPrayerInfo(_ day: PrayerDay) -> (String, String)? {
        let now = Date()
        let pairs: [(String, Date)] = [
            (L10n.Prayer.fajr, day.fajr), (L10n.Prayer.dhuhr, day.dhuhr),
            (L10n.Prayer.asr, day.asr), (L10n.Prayer.maghrib, day.maghrib), (L10n.Prayer.isha, day.isha)
        ]
        for (name, time) in pairs {
            if time > now {
                let diff = time.timeIntervalSince(now)
                let hours = Int(diff) / 3600
                let minutes = (Int(diff) % 3600) / 60
                let remaining = hours > 0
                    ? String(format: "%d:%02d", hours, minutes)
                    : "\(minutes) \(L10n.Common.minuteAbbrev)"
                return (name, remaining)
            }
        }
        return nil
    }

    private func prayerMarkers(for day: PrayerDay) -> [(String, Date)] {
        [
            ("F", day.fajr),
            ("D", day.dhuhr),
            ("A", day.asr),
            ("M", day.maghrib),
            ("I", day.isha)
        ]
    }
}

// MARK: - Upcoming Day Card

private struct UpcomingDayCard: View {
    let day: PrayerDay

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text(day.date, format: .dateTime.weekday(.wide).month().day())
                .font(DS.Typography.headline)
                .foregroundStyle(DS.Color.textPrimary)

            HStack(spacing: 0) {
                miniTime(L10n.Prayer.fajr.prefix(1), time: day.fajr)
                Spacer()
                miniTime(L10n.Prayer.dhuhr.prefix(1), time: day.dhuhr)
                Spacer()
                miniTime(L10n.Prayer.asr.prefix(1), time: day.asr)
                Spacer()
                miniTime(L10n.Prayer.maghrib.prefix(1), time: day.maghrib)
                Spacer()
                miniTime(L10n.Prayer.isha.prefix(1), time: day.isha)
            }
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
    }

    private func miniTime(_ label: Substring, time: Date) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(DS.Typography.micro)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(1)
            Text(time, format: .dateTime.hour().minute())
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(DS.Color.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview("Prayer Times") {
    DSPreview { c in PrayerTimesView(container: c) }
}
