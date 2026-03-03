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
                    ProgressView("Calculating prayer times...")
                        .tint(DS.Color.accent)
                } else if let today = viewModel.todayTimes {
                    List {
                        Section {
                            prayerRow("Fajr", time: today.fajr)
                            prayerRow("Sunrise", time: today.sunrise)
                            prayerRow("Dhuhr", time: today.dhuhr)
                            prayerRow("Asr", time: today.asr)
                            prayerRow("Maghrib", time: today.maghrib)
                            prayerRow("Isha", time: today.isha)
                        } header: {
                            Text("Today")
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
                                Text("Upcoming")
                                    .font(DS.Typography.sectionHead)
                                    .foregroundStyle(DS.Color.textSecondary)
                            }
                            .listRowBackground(DS.Color.backgroundSecondary)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(DS.Color.backgroundPrimary)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    ContentUnavailableView("No Data", systemImage: "clock", description: Text("Prayer times will appear once location is available."))
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Prayer Times")
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
                timeLabel("F", day.fajr)
                timeLabel("D", day.dhuhr)
                timeLabel("A", day.asr)
                timeLabel("M", day.maghrib)
                timeLabel("I", day.isha)
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
