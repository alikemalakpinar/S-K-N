import Foundation

@Observable
final class DuasViewModel {
    var searchQuery = ""
    var searchResults: [DuaDTO] = []
    var isSearching = false
    var errorMessage: String?
    var isStaticDBMissing = false

    private let container: DependencyContainer
    private var searchTask: Task<Void, Never>?

    init(container: DependencyContainer) {
        self.container = container
        self.isStaticDBMissing = !container.isStaticDBAvailable
    }

    func search() {
        searchTask?.cancel()
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty, query.count >= 2 else {
            searchResults = []
            return
        }

        searchTask = Task {
            isSearching = true
            defer { isSearching = false }

            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            guard let repo = container.duaRepository else { return }
            do {
                searchResults = try await repo.searchDuas(query: query, limit: 30)
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
