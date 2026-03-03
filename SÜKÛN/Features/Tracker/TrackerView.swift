import SwiftUI
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TrackerViewModel

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: TrackerViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Space.xl) {
                    // Stats overview
                    statsRow

                    // Reading logs
                    readingSection

                    // Dhikr sessions
                    dhikrSection
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.md)
                .padding(.bottom, DS.Space.x4)
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Takip")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadRecentActivity(context: modelContext)
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: DS.Space.md) {
            StatCard(
                value: "\(viewModel.recentReadingLogs.count)",
                label: "Okuma",
                icon: "book"
            )
            StatCard(
                value: "\(viewModel.recentSessions.count)",
                label: "Zikir",
                icon: "circle.circle"
            )
            StatCard(
                value: totalDhikrCount,
                label: "Toplam",
                icon: "sum"
            )
        }
    }

    private var totalDhikrCount: String {
        let total = viewModel.recentSessions.reduce(0) { $0 + $1.count }
        return "\(total)"
    }

    // MARK: - Reading Section

    private var readingSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("OKUMA")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(2)

            if viewModel.recentReadingLogs.isEmpty {
                emptyState("Henüz okuma kaydı yok", icon: "book.closed")
            } else {
                ForEach(viewModel.recentReadingLogs, id: \.date) { log in
                    HStack(spacing: DS.Space.md) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DS.Color.accent)
                            .frame(width: 3, height: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sure \(log.surahId): \(log.fromVerse)–\(log.toVerse)")
                                .font(DS.Typography.body)
                                .foregroundStyle(DS.Color.textPrimary)
                            Text("\(log.durationSeconds / 60) dk")
                                .font(DS.Typography.captionSm)
                                .foregroundStyle(DS.Color.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, DS.Space.xs)
                }
            }
        }
    }

    // MARK: - Dhikr Section

    private var dhikrSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("ZİKİR SEANSLARI")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(2)

            if viewModel.recentSessions.isEmpty {
                emptyState("Henüz zikir seansı yok", icon: "circle.dashed")
            } else {
                ForEach(viewModel.recentSessions, id: \.date) { session in
                    HStack(spacing: DS.Space.md) {
                        Text("\(session.count)")
                            .font(DS.Typography.title1)
                            .monospacedDigit()
                            .foregroundStyle(DS.Color.textPrimary)
                            .frame(width: 56, alignment: .trailing)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("adet")
                                .font(DS.Typography.captionSm)
                                .foregroundStyle(DS.Color.textSecondary)
                            Text(session.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                                .font(DS.Typography.captionSm)
                                .foregroundStyle(DS.Color.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, DS.Space.xs)
                }
            }
        }
    }

    private func emptyState(_ text: String, icon: String) -> some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(DS.Color.textTertiary)
            Text(text)
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DS.Color.cardElevated)
        )
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: DS.Space.sm) {
            Text(value)
                .font(DS.Typography.title1)
                .monospacedDigit()
                .foregroundStyle(DS.Color.textPrimary)

            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 9))
                Text(label)
                    .font(DS.Typography.micro)
                    .textCase(.uppercase)
            }
            .foregroundStyle(DS.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        )
    }
}
