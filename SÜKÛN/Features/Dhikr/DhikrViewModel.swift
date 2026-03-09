import Foundation
import SwiftData

@Observable
final class DhikrViewModel {
    var currentCount = 0
    var selectedPreset: CounterPreset?
    var presets: [CounterPreset] = []
    var isSessionActive = false

    // History
    var recentSessions: [CounterSession] = []
    var todayTotalCount: Int = 0
    var todaySessionCount: Int = 0

    private var sessionStart: Date?
    private let container: DependencyContainer

    // Preset descriptions (static)
    private static let descriptions: [String: String] = [
        "Sübhânallâh": "Allah'ı tüm eksikliklerden tenzih ederim",
        "Elhamdülillâh": "Hamd Allah'a mahsustur",
        "Allâhü Ekber": "Allah en büyüktür",
    ]

    var presetDescription: String? {
        guard let preset = selectedPreset else { return nil }
        return Self.descriptions[preset.title]
    }

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadPresets(context: ModelContext) {
        let descriptor = FetchDescriptor<CounterPreset>(
            sortBy: [SortDescriptor(\CounterPreset.createdAt)]
        )
        presets = (try? context.fetch(descriptor)) ?? []

        if presets.isEmpty {
            let defaults = [
                CounterPreset(title: "Sübhânallâh", target: 33),
                CounterPreset(title: "Elhamdülillâh", target: 33),
                CounterPreset(title: "Allâhü Ekber", target: 33),
            ]
            defaults.forEach { context.insert($0) }
            try? context.save()
            presets = defaults
        }
    }

    func loadSessionHistory(context: ModelContext) {
        // Recent 30 sessions
        var descriptor = FetchDescriptor<CounterSession>(
            sortBy: [SortDescriptor(\CounterSession.date, order: .reverse)]
        )
        descriptor.fetchLimit = 30
        recentSessions = (try? context.fetch(descriptor)) ?? []

        // Today's totals
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let todayDescriptor = FetchDescriptor<CounterSession>(
            predicate: #Predicate<CounterSession> { $0.date >= startOfDay }
        )
        let todaySessions = (try? context.fetch(todayDescriptor)) ?? []
        todayTotalCount = todaySessions.reduce(0) { $0 + $1.count }
        todaySessionCount = todaySessions.count
    }

    func selectPreset(_ preset: CounterPreset) {
        selectedPreset = preset
        currentCount = 0
        isSessionActive = false
        sessionStart = nil
    }

    func increment() {
        if !isSessionActive {
            isSessionActive = true
            sessionStart = Date()
        }
        currentCount += 1
    }

    func reset() {
        currentCount = 0
        isSessionActive = false
        sessionStart = nil
    }

    func saveSession(context: ModelContext, tourCount: Int = 0) {
        let totalCount: Int
        if tourCount > 0, let preset = selectedPreset {
            // Save total from all completed tours + current partial
            totalCount = (tourCount * preset.target) + currentCount
        } else if currentCount > 0 {
            totalCount = currentCount
        } else {
            return
        }

        let duration = sessionStart.map { Int(Date().timeIntervalSince($0)) } ?? 0
        let session = CounterSession(
            presetTitle: selectedPreset?.title ?? "",
            date: Date(),
            count: totalCount,
            durationSeconds: duration
        )
        context.insert(session)
        do {
            try context.save()
        } catch {
            #if DEBUG
            print("[Dhikr] Session save failed: \(error)")
            #endif
        }
        reset()
    }
}
