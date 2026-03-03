import Foundation
import SwiftData

@Model
final class CounterSession {
    var presetTitle: String = ""
    var date: Date = Date()
    var count: Int = 0
    var durationSeconds: Int = 0

    init(presetTitle: String, date: Date, count: Int, durationSeconds: Int) {
        self.presetTitle = presetTitle
        self.date = date
        self.count = count
        self.durationSeconds = durationSeconds
    }
}
