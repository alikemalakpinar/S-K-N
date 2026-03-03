import Foundation
import SwiftData

@Observable
final class DhikrViewModel {
    var currentCount = 0
    var selectedPreset: CounterPreset?
    var presets: [CounterPreset] = []
    var isSessionActive = false
    private var sessionStart: Date?

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadPresets(context: ModelContext) {
        let descriptor = FetchDescriptor<CounterPreset>(
            sortBy: [SortDescriptor(\CounterPreset.createdAt)]
        )
        presets = (try? context.fetch(descriptor)) ?? []

        // Create default presets if empty
        if presets.isEmpty {
            let defaults = [
                CounterPreset(title: "SubhanAllah", target: 33),
                CounterPreset(title: "Alhamdulillah", target: 33),
                CounterPreset(title: "Allahu Akbar", target: 33),
            ]
            defaults.forEach { context.insert($0) }
            try? context.save()
            presets = defaults
        }
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

    func saveSession(context: ModelContext) {
        guard let start = sessionStart, currentCount > 0 else { return }
        let duration = Int(Date().timeIntervalSince(start))
        let session = CounterSession(
            presetId: selectedPreset?.persistentModelID,
            date: Date(),
            count: currentCount,
            durationSeconds: duration
        )
        context.insert(session)
        try? context.save()
        reset()
    }
}
