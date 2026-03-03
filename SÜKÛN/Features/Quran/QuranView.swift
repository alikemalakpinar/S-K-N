import SwiftUI

struct QuranView: View {
    @State private var viewModel: QuranViewModel
    @State private var activeVerseID: String?

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
            .background(DS.Color.backgroundPrimary)
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
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text(surah.nameEnglish)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(DS.Color.textPrimary)
                    Text(surah.nameTransliteration)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(DS.Color.textSecondary)
                }
                Spacer()
                Text(surah.nameArabic)
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .foregroundStyle(DS.Color.textPrimary)
            }
            .listRowBackground(DS.Color.backgroundPrimary)
            .listRowSeparator(.hidden)
            .overlay(alignment: .bottom) { Hairline() }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DS.Color.backgroundPrimary)
    }

    private var searchResultsList: some View {
        Group {
            if viewModel.isSearching {
                ProgressView()
                    .tint(DS.Color.accent)
            } else if viewModel.searchResults.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchQuery)
            } else {
                List(viewModel.searchResults) { verse in
                    let verseID = "\(verse.surahId):\(verse.verseNumber)"
                    let isActive = activeVerseID == verseID

                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Text(verseID)
                            .font(DS.Typography.caption.bold())
                            .foregroundStyle(DS.Color.accent)

                        Text(verse.textArabic)
                            .font(.system(size: 20, weight: .regular))
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(DS.Color.textPrimary)

                        Text(verse.textTranslation)
                            .font(DS.Typography.body)
                            .foregroundStyle(DS.Color.textSecondary)

                        AccentUnderline(active: isActive)
                    }
                    .padding(.vertical, DS.Space.xs)
                    .opacity(activeVerseID == nil || isActive ? 1.0 : 0.6)
                    .animation(DS.Motion.verse, value: activeVerseID)
                    .listRowBackground(DS.Color.backgroundPrimary)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        withAnimation(DS.Motion.verse) {
                            activeVerseID = isActive ? nil : verseID
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(DS.Color.backgroundPrimary)
            }
        }
    }
}
