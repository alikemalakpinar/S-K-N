import Foundation

struct VerseDTO: Identifiable, Sendable {
    var id: String { "\(surahId):\(verseNumber)" }
    let surahId: Int
    let verseNumber: Int
    let textArabic: String
    let textTranslation: String
    let textTransliteration: String
}
