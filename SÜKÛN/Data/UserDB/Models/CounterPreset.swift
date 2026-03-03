import Foundation
import SwiftData

@Model
final class CounterPreset {
    var title: String = ""
    var target: Int = 33
    var hapticEnabled: Bool = true
    var createdAt: Date = Date()

    init(title: String, target: Int, hapticEnabled: Bool = true) {
        self.title = title
        self.target = target
        self.hapticEnabled = hapticEnabled
        self.createdAt = Date()
    }
}
