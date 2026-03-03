import SwiftUI
import SwiftData
import CoreLocation

struct PrayerTimesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PrayerTimesViewModel
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        _viewModel = State(initialValue: PrayerTimesViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(DS.Color.accent)
                } else if let today = viewModel.todayTimes {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: DS.Space.x2) {
                            todaySection(today)
                            if viewModel.upcomingDays.count > 1 {
                                upcomingSection
                            }
                        }
                        .padding(.horizontal, DS.Space.lg)
                        .padding(.bottom, DS.Space.x4)
                    }
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Hata", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    ContentUnavailableView("Veri Yok", systemImage: "clock", description: Text("Konum erişimi sağlandığında namaz vakitleri görünecektir."))
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Namaz Vakitleri")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await container.locationService.requestPermission()
                do {
                    let coords = try await container.locationService.currentCoordinates()
                    let descriptor = FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" })
                    let settings = (try? modelContext.fetch(descriptor))?.first
                    await viewModel.loadPrayerTimes(
                        latitude: coords.latitude,
                        longitude: coords.longitude,
                        method: settings?.calculationMethod ?? "Turkey",
                        asrMethod: settings?.asrMethod ?? "hanafi"
                    )
                } catch {
                    viewModel.errorMessage = "Konum erişimi sağlanamadı. Lütfen Ayarlar'dan konum iznini etkinleştirin."
                }
            }
        }
    }

    // MARK: - Today

    private func todaySection(_ day: PrayerDay) -> some View {
        VStack(spacing: DS.Space.sm) {
            Text("BUGÜN")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, DS.Space.xs)

            PrayerTimeRow(name: "Sabah", time: day.fajr, isNext: isNext("Sabah", day))
            PrayerTimeRow(name: "Güneş", time: day.sunrise, isNext: false)
            PrayerTimeRow(name: "Öğle", time: day.dhuhr, isNext: isNext("Öğle", day))
            PrayerTimeRow(name: "İkindi", time: day.asr, isNext: isNext("İkindi", day))
            PrayerTimeRow(name: "Akşam", time: day.maghrib, isNext: isNext("Akşam", day))
            PrayerTimeRow(name: "Yatsı", time: day.isha, isNext: isNext("Yatsı", day))
        }
    }

    private func isNext(_ name: String, _ day: PrayerDay) -> Bool {
        let now = Date()
        let pairs: [(String, Date)] = [
            ("Sabah", day.fajr), ("Öğle", day.dhuhr),
            ("İkindi", day.asr), ("Akşam", day.maghrib), ("Yatsı", day.isha)
        ]
        for (n, t) in pairs {
            if t > now { return n == name }
        }
        return false
    }

    // MARK: - Upcoming

    private var upcomingSection: some View {
        VStack(spacing: DS.Space.md) {
            Text("YAKLAŞAN")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, DS.Space.md)

            ForEach(viewModel.upcomingDays.dropFirst(), id: \.date) { day in
                UpcomingDayCard(day: day)
            }
        }
    }
}

// MARK: - Prayer Time Row

private struct PrayerTimeRow: View {
    let name: String
    let time: Date
    let isNext: Bool

    var body: some View {
        HStack {
            // Accent bar for next prayer
            if isNext {
                RoundedRectangle(cornerRadius: 2)
                    .fill(DS.Color.accent)
                    .frame(width: 3, height: 32)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(isNext ? DS.Typography.headline : DS.Typography.body)
                    .foregroundStyle(isNext ? DS.Color.textPrimary : DS.Color.textPrimary)
                if isNext {
                    Text("SONRAKİ")
                        .font(DS.Typography.micro)
                        .foregroundStyle(DS.Color.accent)
                        .tracking(2)
                }
            }

            Spacer()

            Text(time, format: .dateTime.hour().minute())
                .font(isNext
                    ? .system(size: 32, weight: .bold, design: .monospaced)
                    : .system(size: 18, weight: .medium, design: .monospaced))
                .foregroundStyle(isNext ? DS.Color.textPrimary : DS.Color.textSecondary)
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.vertical, isNext ? DS.Space.lg : DS.Space.md)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isNext ? DS.Color.cardElevated : .clear)
                .shadow(color: isNext ? .black.opacity(0.04) : .clear, radius: 8, y: 2)
        )
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
                MiniTime(label: "S", time: day.fajr)
                Spacer()
                MiniTime(label: "Ö", time: day.dhuhr)
                Spacer()
                MiniTime(label: "İ", time: day.asr)
                Spacer()
                MiniTime(label: "A", time: day.maghrib)
                Spacer()
                MiniTime(label: "Y", time: day.isha)
            }
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
    }
}

private struct MiniTime: View {
    let label: String
    let time: Date

    var body: some View {
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
