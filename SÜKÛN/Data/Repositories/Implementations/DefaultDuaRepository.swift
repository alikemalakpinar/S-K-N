import Foundation

final class DefaultDuaRepository: DuaRepository {
    private let dbClient: StaticDBClientProtocol

    init(dbClient: StaticDBClientProtocol) {
        self.dbClient = dbClient
    }

    func searchDuas(query: String, limit: Int = 50) async throws -> [DuaDTO] {
        try await dbClient.searchDuas(query: query, limit: limit)
    }

    func categories() async throws -> [String] {
        try await dbClient.duaCategories()
    }

    func duasByCategory(category: String) async throws -> [DuaDTO] {
        try await dbClient.duasByCategory(category: category)
    }
}
