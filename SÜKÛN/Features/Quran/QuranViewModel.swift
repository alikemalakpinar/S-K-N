import Foundation

@Observable
final class QuranViewModel {
    var searchQuery = ""
    var searchResults: [VerseDTO] = []
    var surahs: [SurahDTO] = []
    var isSearching = false
    var errorMessage: String?
    var isStaticDBMissing = false

    // Mushaf page navigation
    var currentPage = 1
    var totalPages = 604
    var pageVerses: [VerseDTO] = []
    var isLoadingPage = false

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
            totalPages = try await container.quranRepository.pageCount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadPage(_ page: Int) async {
        guard !isStaticDBMissing, page >= 1, page <= totalPages else { return }
        do {
            let verses = try await container.quranRepository.versesForPage(page: page)
            pageVerses = verses
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func jumpToSurah(_ surahId: Int) async -> Int {
        guard !isStaticDBMissing else { return 1 }
        do {
            let page = try await container.quranRepository.pageForSurah(surahId: surahId)
            currentPage = page
            return page
        } catch {
            errorMessage = error.localizedDescription
            return 1
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
