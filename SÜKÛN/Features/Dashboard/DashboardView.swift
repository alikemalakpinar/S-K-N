import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel
    var onOpenRehber: (() -> Void)?

    init(container: DependencyContainer, onOpenRehber: (() -> Void)? = nil) {
        _viewModel = State(initialValue: DashboardViewModel(container: container))
        self.onOpenRehber = onOpenRehber
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Space.xl) {
                    nextPrayerCard
                    todayChecklistCard
                    bilgiTazeleCard
                }
                .padding(DS.Space.lg)
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Sükûn")
            .task {
                await viewModel.loadTodayData(context: modelContext)
            }
        }
    }

    // MARK: - Next Prayer Card

    private var nextPrayerCard: some View {
        DSCard {
            VStack(spacing: DS.Space.md) {
                Text("SONRAKİ VAKİT")
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
                Text("GÜNÜN NAMAZLARI")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(1)

                if let log = viewModel.todayLog {
                    prayerRow("Sabah", status: log.fajr)
                    Hairline()
                    prayerRow("Öğle", status: log.dhuhr)
                    Hairline()
                    prayerRow("İkindi", status: log.asr)
                    Hairline()
                    prayerRow("Akşam", status: log.maghrib)
                    Hairline()
                    prayerRow("Yatsı", status: log.isha)
                } else {
                    Text("Henüz veri yok")
                        .font(DS.Typography.body)
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
        }
    }

    // MARK: - Bilgi Tazele

    private var bilgiTazeleCard: some View {
        Button {
            onOpenRehber?()
        } label: {
            DSCard {
                HStack(spacing: DS.Space.lg) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(DS.Color.accent)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        Text("Bilgi Tazele")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(DS.Color.textPrimary)
                        Text("Temel esaslar ve hatırlatmalar.")
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
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
