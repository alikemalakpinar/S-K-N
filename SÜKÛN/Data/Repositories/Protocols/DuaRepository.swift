import Foundation

protocol DuaRepository: Sendable {
    func searchDuas(query: String, limit: Int) async throws -> [DuaDTO]
}
