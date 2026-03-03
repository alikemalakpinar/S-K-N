import Foundation

struct DuaDTO: Identifiable, Sendable {
    let id: Int
    let title: String
    let textArabic: String
    let textTranslation: String
    let textTransliteration: String
    let category: String
    let source: String
}
