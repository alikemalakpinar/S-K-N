import Foundation

struct SurahDTO: Identifiable, Sendable {
    let id: Int
    let nameArabic: String
    let nameEnglish: String
    let nameTransliteration: String
    let verseCount: Int
    let revelationType: String // "Meccan" or "Medinan"
}
