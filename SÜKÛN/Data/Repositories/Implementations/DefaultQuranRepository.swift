import Foundation

final class DefaultQuranRepository: QuranRepository {
    private let dbClient: StaticDBClientProtocol

    init(dbClient: StaticDBClientProtocol) {
        self.dbClient = dbClient
    }

    func searchVerses(query: String, limit: Int = 50) async throws -> [VerseDTO] {
        try await dbClient.searchVerses(query: query, limit: limit)
    }

    func allSurahs() async throws -> [SurahDTO] {
        try await dbClient.allSurahs()
    }

    func verses(forSurah surahId: Int) async throws -> [VerseDTO] {
        try await dbClient.verses(forSurah: surahId)
    }

    func versesForPage(page: Int) async throws -> [VerseDTO] {
        try await dbClient.versesForPage(page: page)
    }

    func pageCount() async throws -> Int {
        try await dbClient.pageCount()
    }

    func pageForSurah(surahId: Int) async throws -> Int {
        try await dbClient.pageForSurah(surahId: surahId)
    }

    func randomVerse() async throws -> VerseDTO {
        try await dbClient.randomVerse()
    }
}
