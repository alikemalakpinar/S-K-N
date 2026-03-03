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
                } else if let today = viewModel.todayTimes {
                    List {
                        Section("Today") {
                            prayerRow("Fajr", time: today.fajr)
                            prayerRow("Sunrise", time: today.sunrise)
                            prayerRow("Dhuhr", time: today.dhuhr)
                            prayerRow("Asr", time: today.asr)
                            prayerRow("Maghrib", time: today.maghrib)
                            prayerRow("Isha", time: today.isha)
                        }

                        if viewModel.upcomingDays.count > 1 {
                            Section("Upcoming") {
                                ForEach(viewModel.upcomingDays.dropFirst(), id: \.date) { day in
                                    dayRow(day)
                                }
                            }
                        }
                    }
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    ContentUnavailableView("No Data", systemImage: "clock", description: Text("Prayer times will appear once location is available."))
                }
            }
            .navigationTitle("Prayer Times")
        }
    }

    private func prayerRow(_ name: String, time: Date) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(time, format: .dateTime.hour().minute())
                .monospacedDigit()
        }
    }

    private func dayRow(_ day: PrayerDay) -> some View {
        VStack(alignment: .leading) {
            Text(day.date, format: .dateTime.weekday(.wide).month().day())
                .font(.subheadline.bold())
            HStack(spacing: 12) {
                timeLabel("F", day.fajr)
                timeLabel("D", day.dhuhr)
                timeLabel("A", day.asr)
                timeLabel("M", day.maghrib)
                timeLabel("I", day.isha)
            }
            .font(.caption)
            .monospacedDigit()
        }
    }

    private func timeLabel(_ letter: String, _ time: Date) -> some View {
        VStack {
            Text(letter)
                .foregroundStyle(.secondary)
            Text(time, format: .dateTime.hour().minute())
        }
    }
}
