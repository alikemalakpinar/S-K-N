import SwiftUI

enum QuranSegment: String, CaseIterable {
    case mushaf = "Mushaf"
    case sureler = "Sureler"
    case rehber = "Rehber"
}

struct QuranView: View {
    @State private var viewModel: QuranViewModel
    @State private var activeVerseID: String?
    @Binding var selectedSegment: QuranSegment
    let container: DependencyContainer

    init(container: DependencyContainer, selectedSegment: Binding<QuranSegment>) {
        _viewModel = State(initialValue: QuranViewModel(container: container))
        _selectedSegment = selectedSegment
        self.container = container
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedSegment) {
                    ForEach(QuranSegment.allCases, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DS.Space.lg)
                .padding(.vertical, DS.Space.sm)

                Group {
                    switch selectedSegment {
                    case .mushaf:
                        mushafContent
                    case .sureler:
                        surelerContent
                    case .rehber:
                        RehberView(container: container)
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Kur'an")
            .searchable(
                text: $viewModel.searchQuery,
                prompt: "Ayet ara..."
            )
            .onChange(of: selectedSegment) {
                if selectedSegment != .sureler {
                    viewModel.searchQuery = ""
                }
            }
            .onChange(of: viewModel.searchQuery) {
                viewModel.search()
            }
            .task {
                await viewModel.loadSurahs()
            }
        }
    }

    // MARK: - Mushaf Content

    @ViewBuilder
    private var mushafContent: some View {
        if viewModel.isStaticDBMissing {
            dbMissingView
        } else {
            MushafReaderView(viewModel: viewModel, container: container)
        }
    }

    // MARK: - Sureler Content

    @ViewBuilder
    private var surelerContent: some View {
        if viewModel.isStaticDBMissing {
            dbMissingView
        } else if !viewModel.searchQuery.isEmpty {
            searchResultsList
        } else {
            surahList
        }
    }

    private var dbMissingView: some View {
        ContentUnavailableView(
            "Veritabanı Bulunamadı",
            systemImage: "externaldrive.badge.exclamationmark",
            description: Text("Kur'an veritabanı (sukun_static.sqlite) uygulamada bulunamadı.")
        )
    }

    private var surahList: some View {
        List(viewModel.surahs) { surah in
            NavigationLink(value: surah.id) {
                HStack {
                    Text("\(surah.id)")
                        .font(DS.Typography.caption)
                        .foregroundStyle(DS.Color.textSecondary)
                        .frame(width: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(surah.nameTurkish)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(DS.Color.textPrimary)
                        Text("\(surah.verseCount) ayet \u{2022} \(surah.revelationType == "Meccan" ? "Mekki" : "Medeni")")
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                    Spacer()
                    Text(surah.nameArabic)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(DS.Color.textPrimary)
                }
            }
            .listRowBackground(DS.Color.backgroundPrimary)
            .listRowSeparator(.hidden)
            .overlay(alignment: .bottom) { Hairline() }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DS.Color.backgroundPrimary)
        .navigationDestination(for: Int.self) { surahId in
            SurahDetailView(surahId: surahId, container: container)
        }
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
                        HStack {
                            Text(verseID)
                                .font(DS.Typography.caption.bold())
                                .foregroundStyle(DS.Color.accent)
                            Spacer()
                            Text("Sayfa \(verse.pageNumber)")
                                .font(DS.Typography.captionSm)
                                .foregroundStyle(DS.Color.textSecondary)
                        }

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

// MARK: - Surah Detail View

struct SurahDetailView: View {
    let surahId: Int
    let container: DependencyContainer

    @State private var verses: [VerseDTO] = []
    @State private var surahName = ""
    @State private var selectedVerse: VerseDTO?

    var body: some View {
        List(verses) { verse in
            Button {
                selectedVerse = verse
            } label: {
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    HStack(alignment: .top) {
                        Text("\(verse.verseNumber)")
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.accent)
                            .frame(width: 24)
                        Spacer()
                        Text(verse.textArabic)
                            .font(.system(size: 20, weight: .regular))
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(DS.Color.textPrimary)
                            .lineSpacing(8)
                    }
                    Text(verse.textTranslation)
                        .font(DS.Typography.caption)
                        .foregroundStyle(DS.Color.textSecondary)
                        .lineSpacing(3)
                }
                .padding(.vertical, DS.Space.xs)
            }
            .buttonStyle(.plain)
            .listRowBackground(DS.Color.backgroundPrimary)
            .listRowSeparator(.hidden)
            .overlay(alignment: .bottom) { Hairline() }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DS.Color.backgroundPrimary)
        .navigationTitle(surahName)
        .navigationBarTitleDisplayMode(.large)
        .task {
            do {
                verses = try await container.quranRepository.verses(forSurah: surahId)
                let surahs = try await container.quranRepository.allSurahs()
                surahName = surahs.first(where: { $0.id == surahId })?.nameTurkish ?? ""
            } catch {}
        }
        .sheet(item: $selectedVerse) { verse in
            VerseDetailSheet(verse: verse, surahName: surahName)
        }
    }
}
