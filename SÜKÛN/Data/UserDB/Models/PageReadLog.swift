import Foundation
import SwiftData

@Model
final class PageReadLog {
    var pageNumber: Int = 0
    var date: Date = Date()

    init(pageNumber: Int, date: Date = Date()) {
        self.pageNumber = pageNumber
        self.date = date
    }
}
