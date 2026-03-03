import Foundation

@Observable
final class QuranViewModel {
    var searchQuery = ""
    var searchResults: [VerseDTO] = []
    var surahs: [SurahDTO] = []
    var isSearching = false
    var errorMessage: String?
    var isStaticDBMissing = false

    private let container: DependencyContainer
    private var searchTask: Task<Void, Never>?

    init(container: DependencyContainer) {
        self.container = container
        self.isStaticDBMissing = !container.isStaticDBAvailable
    }

    func loadSurahs() async {
        guard !isStaticDBMissing else { return }
        do {
            surahs = try await container.quranRepository.allSurahs()
        } catch {
            errorMessage = error.localizedDescription
        }
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

            // Debounce: 300ms
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            do {
                searchResults = try await container.quranRepository.searchVerses(query: query, limit: 30)
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
