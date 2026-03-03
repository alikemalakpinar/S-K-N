import SwiftUI

struct PrayerTimesView: View {
    @State private var viewModel: PrayerTimesViewModel

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: PrayerTimesViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Namaz vakitleri hesaplanıyor...")
                        .tint(DS.Color.accent)
                } else if let today = viewModel.todayTimes {
                    List {
                        Section {
                            prayerRow("Sabah", time: today.fajr)
                            prayerRow("Güneş", time: today.sunrise)
                            prayerRow("Öğle", time: today.dhuhr)
                            prayerRow("İkindi", time: today.asr)
                            prayerRow("Akşam", time: today.maghrib)
                            prayerRow("Yatsı", time: today.isha)
                        } header: {
                            Text("Bugün")
                                .font(DS.Typography.sectionHead)
                                .foregroundStyle(DS.Color.textSecondary)
                        }
                        .listRowBackground(DS.Color.backgroundSecondary)

                        if viewModel.upcomingDays.count > 1 {
                            Section {
                                ForEach(viewModel.upcomingDays.dropFirst(), id: \.date) { day in
                                    dayRow(day)
                                }
                            } header: {
                                Text("Yaklaşan")
                                    .font(DS.Typography.sectionHead)
                                    .foregroundStyle(DS.Color.textSecondary)
                            }
                            .listRowBackground(DS.Color.backgroundSecondary)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(DS.Color.backgroundPrimary)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Hata", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    ContentUnavailableView("Veri Yok", systemImage: "clock", description: Text("Konum erişimi sağlandığında namaz vakitleri görünecektir."))
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Namaz Vakitleri")
        }
    }

    private func prayerRow(_ name: String, time: Date) -> some View {
        HStack {
            Text(name)
                .font(DS.Typography.body)
                .foregroundStyle(DS.Color.textPrimary)
            Spacer()
            Text(time, format: .dateTime.hour().minute())
                .monospacedDigit()
                .font(DS.Typography.body)
                .foregroundStyle(DS.Color.textSecondary)
        }
    }

    private func dayRow(_ day: PrayerDay) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(day.date, format: .dateTime.weekday(.wide).month().day())
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(DS.Color.textPrimary)
            HStack(spacing: DS.Space.md) {
                timeLabel("S", day.fajr)
                timeLabel("Ö", day.dhuhr)
                timeLabel("İ", day.asr)
                timeLabel("A", day.maghrib)
                timeLabel("Y", day.isha)
            }
            .font(DS.Typography.caption)
            .monospacedDigit()
        }
    }

    private func timeLabel(_ letter: String, _ time: Date) -> some View {
        VStack {
            Text(letter)
                .foregroundStyle(DS.Color.textSecondary)
            Text(time, format: .dateTime.hour().minute())
                .foregroundStyle(DS.Color.textPrimary)
        }
    }
}
