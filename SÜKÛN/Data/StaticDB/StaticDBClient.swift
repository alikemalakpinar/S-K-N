import Foundation
import GRDB

enum StaticDBError: LocalizedError {
    case databaseNotFound
    case databaseCorrupted(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .databaseNotFound:
            return "Static database file not found in app bundle at Resources/Data/sukun_static.sqlite. Please add the pre-populated SQLite database."
        case .databaseCorrupted(let error):
            return "Static database is corrupted: \(error.localizedDescription)"
        }
    }
}

protocol StaticDBClientProtocol: Sendable {
    func searchVerses(query: String, limit: Int) async throws -> [VerseDTO]
    func searchDuas(query: String, limit: Int) async throws -> [DuaDTO]
    func allSurahs() async throws -> [SurahDTO]
    func verses(forSurah surahId: Int) async throws -> [VerseDTO]
    func versesForPage(page: Int) async throws -> [VerseDTO]
    func pageCount() async throws -> Int
    func pageForSurah(surahId: Int) async throws -> Int
}

/// Lightweight fallback when the static database is missing or corrupted.
/// All methods throw `databaseNotFound` so that callers degrade gracefully.
final class NoopStaticDBClient: StaticDBClientProtocol, Sendable {
    func searchVerses(query: String, limit: Int) async throws -> [VerseDTO] {
        throw StaticDBError.databaseNotFound
    }
    func searchDuas(query: String, limit: Int) async throws -> [DuaDTO] {
        throw StaticDBError.databaseNotFound
    }
    func allSurahs() async throws -> [SurahDTO] {
        throw StaticDBError.databaseNotFound
    }
    func verses(forSurah surahId: Int) async throws -> [VerseDTO] {
        throw StaticDBError.databaseNotFound
    }
    func versesForPage(page: Int) async throws -> [VerseDTO] {
        throw StaticDBError.databaseNotFound
    }
    func pageCount() async throws -> Int {
        throw StaticDBError.databaseNotFound
    }
    func pageForSurah(surahId: Int) async throws -> Int {
        throw StaticDBError.databaseNotFound
    }
}

final class StaticDBClient: StaticDBClientProtocol, Sendable {
    private let dbQueue: DatabaseQueue

    init() throws {
        guard let dbURL = Bundle.main.url(forResource: "sukun_static", withExtension: "sqlite")
                ?? Bundle.main.url(forResource: "sukun_static", withExtension: "sqlite", subdirectory: "Resources/Data") else {
            throw StaticDBError.databaseNotFound
        }

        do {
            var config = Configuration()
            config.readonly = true
            dbQueue = try DatabaseQueue(path: dbURL.path, configuration: config)
        } catch {
            throw StaticDBError.databaseCorrupted(underlying: error)
        }
    }

    // MARK: - FTS Search

    func searchVerses(query: String, limit: Int = 50) async throws -> [VerseDTO] {
        let sanitized = sanitizeFTSQuery(query)
        guard !sanitized.isEmpty else { return [] }

        return try await dbQueue.read { db in
            let sql = """
                SELECT v.surah_id, v.verse_number, v.text_arabic, v.text_translation,
                       v.text_transliteration, v.text_tefsir, v.page_number
                FROM verses_fts fts
                JOIN verses v ON v.rowid = fts.rowid
                WHERE verses_fts MATCH ?
                ORDER BY bm25(verses_fts)
                LIMIT ?
                """
            let rows = try Row.fetchAll(db, sql: sql, arguments: [sanitized + "*", limit])
            return rows.map { Self.verseFromRow($0) }
        }
    }

    func searchDuas(query: String, limit: Int = 50) async throws -> [DuaDTO] {
        let sanitized = sanitizeFTSQuery(query)
        guard !sanitized.isEmpty else { return [] }

        return try await dbQueue.read { db in
            let sql = """
                SELECT d.id, d.title, d.text_arabic, d.text_translation, d.text_transliteration, d.category, d.source
                FROM duas_fts fts
                JOIN duas d ON d.rowid = fts.rowid
                WHERE duas_fts MATCH ?
                ORDER BY bm25(duas_fts)
                LIMIT ?
                """
            let rows = try Row.fetchAll(db, sql: sql, arguments: [sanitized + "*", limit])
            return rows.map { row in
                DuaDTO(
                    id: row["id"],
                    title: row["title"],
                    textArabic: row["text_arabic"],
                    textTranslation: row["text_translation"],
                    textTransliteration: row["text_transliteration"],
                    category: row["category"],
                    source: row["source"]
                )
            }
        }
    }

    // MARK: - Browse

    func allSurahs() async throws -> [SurahDTO] {
        try await dbQueue.read { db in
            let sql = """
                SELECT id, name_arabic, name_english, name_transliteration, name_turkish, verse_count, revelation_type
                FROM surahs ORDER BY id
                """
            let rows = try Row.fetchAll(db, sql: sql)
            return rows.map { row in
                SurahDTO(
                    id: row["id"],
                    nameArabic: row["name_arabic"],
                    nameEnglish: row["name_english"],
                    nameTransliteration: row["name_transliteration"],
                    nameTurkish: row["name_turkish"],
                    verseCount: row["verse_count"],
                    revelationType: row["revelation_type"]
                )
            }
        }
    }

    func verses(forSurah surahId: Int) async throws -> [VerseDTO] {
        try await dbQueue.read { db in
            let sql = """
                SELECT surah_id, verse_number, text_arabic, text_translation,
                       text_transliteration, text_tefsir, page_number
                FROM verses WHERE surah_id = ? ORDER BY verse_number
                """
            let rows = try Row.fetchAll(db, sql: sql, arguments: [surahId])
            return rows.map { Self.verseFromRow($0) }
        }
    }

    // MARK: - Mushaf Page Queries

    func versesForPage(page: Int) async throws -> [VerseDTO] {
        try await dbQueue.read { db in
            let sql = """
                SELECT surah_id, verse_number, text_arabic, text_translation,
                       text_transliteration, text_tefsir, page_number
                FROM verses WHERE page_number = ? ORDER BY surah_id, verse_number
                """
            let rows = try Row.fetchAll(db, sql: sql, arguments: [page])
            return rows.map { Self.verseFromRow($0) }
        }
    }

    func pageCount() async throws -> Int {
        try await dbQueue.read { db in
            let row = try Row.fetchOne(db, sql: "SELECT MAX(page_number) as max_page FROM verses")
            return row?["max_page"] as? Int ?? 604
        }
    }

    func pageForSurah(surahId: Int) async throws -> Int {
        try await dbQueue.read { db in
            let sql = "SELECT MIN(page_number) as start_page FROM verses WHERE surah_id = ?"
            let row = try Row.fetchOne(db, sql: sql, arguments: [surahId])
            return row?["start_page"] as? Int ?? 1
        }
    }

    // MARK: - Helpers

    private nonisolated static func verseFromRow(_ row: Row) -> VerseDTO {
        VerseDTO(
            surahId: row["surah_id"],
            verseNumber: row["verse_number"],
            textArabic: row["text_arabic"],
            textTranslation: row["text_translation"],
            textTransliteration: row["text_transliteration"],
            textTefsir: row["text_tefsir"],
            pageNumber: row["page_number"]
        )
    }

    private func sanitizeFTSQuery(_ query: String) -> String {
        // Remove FTS5 special characters to prevent injection
        let cleaned = query
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned
    }
}
