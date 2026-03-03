import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: DashboardViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    nextPrayerCard
                    todayChecklistCard
                }
                .padding()
            }
            .navigationTitle("Sukun")
            .task {
                await viewModel.loadTodayData(context: modelContext)
            }
        }
    }

    // MARK: - Next Prayer Card

    private var nextPrayerCard: some View {
        VStack(spacing: 12) {
            Text("Next Prayer")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.nextPrayerName)
                .font(.title.bold())

            if let time = viewModel.nextPrayerTime {
                Text(time, style: .relative)
                    .font(.title2)
                    .monospacedDigit()
            } else {
                Text("--:--")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Today Checklist

    private var todayChecklistCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Prayers")
                .font(.headline)

            if let log = viewModel.todayLog {
                prayerRow("Fajr", status: log.fajr)
                prayerRow("Dhuhr", status: log.dhuhr)
                prayerRow("Asr", status: log.asr)
                prayerRow("Maghrib", status: log.maghrib)
                prayerRow("Isha", status: log.isha)
            } else {
                Text("No data yet")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func prayerRow(_ name: String, status: PrayerStatus) -> some View {
        HStack {
            Image(systemName: status == .prayed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(status == .prayed ? .green : .secondary)
            Text(name)
            Spacer()
            Text(status.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
