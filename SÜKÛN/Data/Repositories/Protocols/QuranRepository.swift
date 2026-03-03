import Foundation

protocol QuranRepository: Sendable {
    func searchVerses(query: String, limit: Int) async throws -> [VerseDTO]
    func allSurahs() async throws -> [SurahDTO]
    func verses(forSurah surahId: Int) async throws -> [VerseDTO]
    func versesForPage(page: Int) async throws -> [VerseDTO]
    func pageCount() async throws -> Int
    func pageForSurah(surahId: Int) async throws -> Int
}
