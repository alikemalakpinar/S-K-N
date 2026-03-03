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
                VStack(spacing: DS.Space.xl) {
                    nextPrayerCard
                    todayChecklistCard
                }
                .padding(DS.Space.lg)
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Sukun")
            .task {
                await viewModel.loadTodayData(context: modelContext)
            }
        }
    }

    // MARK: - Next Prayer Card

    private var nextPrayerCard: some View {
        DSCard {
            VStack(spacing: DS.Space.md) {
                Text("NEXT PRAYER")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(1)

                Text(viewModel.nextPrayerName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(DS.Color.textPrimary)

                if let time = viewModel.nextPrayerTime {
                    Text(time, style: .relative)
                        .font(DS.Typography.hero)
                        .monospacedDigit()
                        .foregroundStyle(DS.Color.textPrimary)
                } else {
                    Text("--:--")
                        .font(DS.Typography.hero)
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.lg)
        }
    }

    // MARK: - Today Checklist

    private var todayChecklistCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                Text("TODAY'S PRAYERS")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(1)

                if let log = viewModel.todayLog {
                    prayerRow("Fajr", status: log.fajr)
                    Hairline()
                    prayerRow("Dhuhr", status: log.dhuhr)
                    Hairline()
                    prayerRow("Asr", status: log.asr)
                    Hairline()
                    prayerRow("Maghrib", status: log.maghrib)
                    Hairline()
                    prayerRow("Isha", status: log.isha)
                } else {
                    Text("No data yet")
                        .font(DS.Typography.body)
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
        }
    }

    private func prayerRow(_ name: String, status: PrayerStatus) -> some View {
        HStack {
            Image(systemName: status == .prayed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(status == .prayed ? DS.Color.accent : DS.Color.textSecondary)
            Text(name)
                .font(DS.Typography.body)
                .foregroundStyle(DS.Color.textPrimary)
            Spacer()
            Text(status.rawValue.capitalized)
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .padding(.vertical, DS.Space.xs)
    }
}
