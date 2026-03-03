import SwiftUI

struct QuranView: View {
    @State private var viewModel: QuranViewModel

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: QuranViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isStaticDBMissing {
                    ContentUnavailableView(
                        "Database Not Found",
                        systemImage: "externaldrive.badge.exclamationmark",
                        description: Text("The Quran database (sukun_static.sqlite) is not bundled with the app. See README for setup instructions.")
                    )
                } else if !viewModel.searchQuery.isEmpty {
                    searchResultsList
                } else {
                    surahList
                }
            }
            .navigationTitle("Quran")
            .searchable(text: $viewModel.searchQuery, prompt: "Search verses...")
            .onChange(of: viewModel.searchQuery) {
                viewModel.search()
            }
            .task {
                await viewModel.loadSurahs()
            }
        }
    }

    private var surahList: some View {
        List(viewModel.surahs) { surah in
            HStack {
                Text("\(surah.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 30)
                VStack(alignment: .leading) {
                    Text(surah.nameEnglish)
                        .font(.body)
                    Text(surah.nameTransliteration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(surah.nameArabic)
                    .font(.title3)
            }
        }
    }

    private var searchResultsList: some View {
        Group {
            if viewModel.isSearching {
                ProgressView()
            } else if viewModel.searchResults.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchQuery)
            } else {
                List(viewModel.searchResults) { verse in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(verse.surahId):\(verse.verseNumber)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text(verse.textArabic)
                            .font(.title3)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text(verse.textTranslation)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
