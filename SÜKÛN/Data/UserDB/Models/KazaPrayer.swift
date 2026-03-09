import Foundation
import SwiftData

@Model
final class KazaPrayer {
    @Attribute(.unique) var id: String = "default"
    var fajrCount: Int = 0
    var dhuhrCount: Int = 0
    var asrCount: Int = 0
    var maghribCount: Int = 0
    var ishaCount: Int = 0
    var vitrCount: Int = 0
    var updatedAt: Date = Date()

    init() {}

    var totalCount: Int {
        fajrCount + dhuhrCount + asrCount + maghribCount + ishaCount + vitrCount
    }
}
