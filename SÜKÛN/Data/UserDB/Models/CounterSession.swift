import Foundation
import SwiftData

@Model
final class CounterSession {
    var presetId: PersistentIdentifier?
    var date: Date = Date()
    var count: Int = 0
    var durationSeconds: Int = 0

    init(presetId: PersistentIdentifier?, date: Date, count: Int, durationSeconds: Int) {
        self.presetId = presetId
        self.date = date
        self.count = count
        self.durationSeconds = durationSeconds
    }
}
