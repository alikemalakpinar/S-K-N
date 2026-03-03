import Foundation
import SwiftData

@Model
final class FavoriteItem {
    var type: FavoriteType = .verse
    var refId: String = ""
    var createdAt: Date = Date()

    init(type: FavoriteType, refId: String) {
        self.type = type
        self.refId = refId
        self.createdAt = Date()
    }
}

enum FavoriteType: String, Codable {
    case verse
    case surah
    case dua
}
