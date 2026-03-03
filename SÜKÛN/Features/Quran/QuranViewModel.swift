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
    var currentJuzNumber: Int { juzForPage(currentPage) }

    /// Returns the surah info for the first verse on the given page
    func surahInfoForCurrentPage() -> (id: Int, name: String)? {
        guard let firstVerse = pageVerses.first else { return nil }
        let name = surahs.first(where: { $0.id == firstVerse.surahId })?.nameTurkish ?? ""
        return (firstVerse.surahId, name)
    }

    private func juzForPage(_ page: Int) -> Int {
        // Standard Medina Mushaf juz boundaries (page numbers)
        let juzStartPages = [1,22,42,62,82,102,121,142,162,182,
                             201,222,242,262,282,302,322,342,362,382,
                             402,422,442,462,482,502,522,542,562,582]
        for i in stride(from: juzStartPages.count - 1, through: 0, by: -1) {
            if page >= juzStartPages[i] {
                return i + 1
            }
        }
        return 1
    }

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
            errorMessage = UserFriendlyError.message(from: error)
        }
    }

    func loadPage(_ page: Int) async {
        guard !isStaticDBMissing, page >= 1, page <= totalPages else { return }
        do {
            let verses = try await container.quranRepository.versesForPage(page: page)
            pageVerses = verses
        } catch {
            errorMessage = UserFriendlyError.message(from: error)
        }
    }

    func jumpToSurah(_ surahId: Int) async -> Int {
        guard !isStaticDBMissing else { return 1 }
        do {
            let page = try await container.quranRepository.pageForSurah(surahId: surahId)
            currentPage = page
            return page
        } catch {
            errorMessage = UserFriendlyError.message(from: error)
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
                    errorMessage = UserFriendlyError.message(from: error)
                }
            }
        }
    }
}
