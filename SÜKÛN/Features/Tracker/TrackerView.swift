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
            List {
                Section {
                    if viewModel.recentReadingLogs.isEmpty {
                        Text("Henüz okuma kaydı yok.")
                            .font(DS.Typography.body)
                            .foregroundStyle(DS.Color.textSecondary)
                    } else {
                        ForEach(viewModel.recentReadingLogs, id: \.date) { log in
                            HStack {
                                Text("Sure \(log.surahId): \(log.fromVerse)-\(log.toVerse)")
                                    .font(DS.Typography.body)
                                    .foregroundStyle(DS.Color.textPrimary)
                                Spacer()
                                Text("\(log.durationSeconds / 60) dk")
                                    .font(DS.Typography.caption)
                                    .foregroundStyle(DS.Color.textSecondary)
                            }
                        }
                    }
                } header: {
                    Text("Okuma (Son 7 Gün)")
                        .font(DS.Typography.sectionHead)
                        .foregroundStyle(DS.Color.textSecondary)
                }
                .listRowBackground(DS.Color.backgroundSecondary)

                Section {
                    if viewModel.recentSessions.isEmpty {
                        Text("Henüz zikir seansı yok.")
                            .font(DS.Typography.body)
                            .foregroundStyle(DS.Color.textSecondary)
                    } else {
                        ForEach(viewModel.recentSessions, id: \.date) { session in
                            HStack {
                                Text("\(session.count) adet")
                                    .font(DS.Typography.body)
                                    .foregroundStyle(DS.Color.textPrimary)
                                Spacer()
                                Text(session.date, format: .dateTime.month().day().hour().minute())
                                    .font(DS.Typography.caption)
                                    .foregroundStyle(DS.Color.textSecondary)
                            }
                        }
                    }
                } header: {
                    Text("Zikir Seansları (Son 7 Gün)")
                        .font(DS.Typography.sectionHead)
                        .foregroundStyle(DS.Color.textSecondary)
                }
                .listRowBackground(DS.Color.backgroundSecondary)
            }
            .scrollContentBackground(.hidden)
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Takip")
            .task {
                viewModel.loadRecentActivity(context: modelContext)
            }
        }
    }
}
