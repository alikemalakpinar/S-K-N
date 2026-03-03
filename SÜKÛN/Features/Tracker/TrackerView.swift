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
                Section("Reading (Last 7 Days)") {
                    if viewModel.recentReadingLogs.isEmpty {
                        Text("No reading sessions yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.recentReadingLogs, id: \.date) { log in
                            HStack {
                                Text("Surah \(log.surahId): \(log.fromVerse)-\(log.toVerse)")
                                Spacer()
                                Text("\(log.durationSeconds / 60) min")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Dhikr Sessions (Last 7 Days)") {
                    if viewModel.recentSessions.isEmpty {
                        Text("No dhikr sessions yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.recentSessions, id: \.date) { session in
                            HStack {
                                Text("\(session.count) counts")
                                Spacer()
                                Text(session.date, format: .dateTime.month().day().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tracker")
            .task {
                viewModel.loadRecentActivity(context: modelContext)
            }
        }
    }
}
