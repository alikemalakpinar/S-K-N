import Foundation
import SwiftData

@Model
final class LastReadPosition {
    @Attribute(.unique) var id: String = "current"
    var mushafPage: Int = 1
    var surahId: Int = 1
    var verseNumber: Int = 1
    var surahNameTurkish: String = "Fâtiha"
    var updatedAt: Date = Date()

    init() {}
}
