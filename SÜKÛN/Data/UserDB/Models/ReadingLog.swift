import Foundation
import SwiftData

@Model
final class ReadingLog {
    var date: Date = Date()
    var surahId: Int = 0
    var fromVerse: Int = 0
    var toVerse: Int = 0
    var durationSeconds: Int = 0

    init(date: Date, surahId: Int, fromVerse: Int, toVerse: Int, durationSeconds: Int) {
        self.date = date
        self.surahId = surahId
        self.fromVerse = fromVerse
        self.toVerse = toVerse
        self.durationSeconds = durationSeconds
    }
}
