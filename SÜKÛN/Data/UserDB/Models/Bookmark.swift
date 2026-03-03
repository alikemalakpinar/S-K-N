import Foundation
import SwiftData

@Model
final class Bookmark {
    var type: BookmarkType = .verse
    var refId: String = ""
    var note: String = ""
    var createdAt: Date = Date()

    init(type: BookmarkType, refId: String, note: String = "") {
        self.type = type
        self.refId = refId
        self.note = note
        self.createdAt = Date()
    }
}

enum BookmarkType: String, Codable {
    case verse
    case dua
    case page
}
