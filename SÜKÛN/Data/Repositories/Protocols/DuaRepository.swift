import Foundation

protocol DuaRepository: Sendable {
    func searchDuas(query: String, limit: Int) async throws -> [DuaDTO]
    func categories() async throws -> [String]
    func duasByCategory(category: String) async throws -> [DuaDTO]
}
