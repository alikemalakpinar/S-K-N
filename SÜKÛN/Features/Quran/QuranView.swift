import SwiftUI

enum QuranSegment: String, CaseIterable {
    case mushaf = "Mushaf"
    case sureler = "Sureler"
    case rehber = "Rehber"
}

struct QuranView: View {
    @State private var viewModel: QuranViewModel
    @State private var activeVerseID: String?
    @State private var isImmersive = false
    @Binding var selectedSegment: QuranSegment
    @Binding var resumePage: Int?
    let container: DependencyContainer

    init(container: DependencyContainer, selectedSegment: Binding<QuranSegment>, resumePage: Binding<Int?> = .constant(nil)) {
        _viewModel = State(initialValue: QuranViewModel(container: container))
        _selectedSegment = selectedSegment
        _resumePage = resumePage
        self.container = container
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !isImmersive {
                    Picker("", selection: $selectedSegment) {
                        ForEach(QuranSegment.allCases, id: \.self) { segment in
                            Text(segment.rawValue).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.vertical, DS.Space.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

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
            .navigationTitle(isImmersive ? "" : "Kur'an")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(isImmersive ? .hidden : .visible, for: .navigationBar)
            .toolbar(isImmersive ? .hidden : .visible, for: .tabBar)
            .searchable(
                text: $viewModel.searchQuery,
                prompt: "Ayet ara..."
            )
            .onChange(of: selectedSegment) {
                if selectedSegment != .sureler {
                    viewModel.searchQuery = ""
                }
                if selectedSegment != .mushaf && isImmersive {
                    withAnimation(DS.Motion.standard) { isImmersive = false }
                }
            }
            .onChange(of: viewModel.searchQuery) {
                viewModel.search()
            }
            .task {
                await viewModel.loadSurahs()
            }
            .onChange(of: resumePage) { _, newPage in
                if let page = newPage {
                    viewModel.currentPage = page
                    selectedSegment = .mushaf
                    resumePage = nil
                }
            }
        }
    }

    // MARK: - Mushaf Content

    @ViewBuilder
    private var mushafContent: some View {
        if viewModel.isStaticDBMissing {
            dbMissingView
        } else {
            MushafReaderView(viewModel: viewModel, container: container, isImmersive: $isImmersive)
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

    // MARK: - Surah List (tapping jumps to Mushaf page)

    private var surahList: some View {
        List(viewModel.surahs) { surah in
            Button {
                Task {
                    let page = await viewModel.jumpToSurah(surah.id)
                    viewModel.currentPage = page
                    selectedSegment = .mushaf
                }
            } label: {
                HStack(spacing: DS.Space.md) {
                    // Ornamental number badge
                    ZStack {
                        Image(systemName: "seal.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(DS.Color.accentSoft)
                        Image(systemName: "seal")
                            .font(.system(size: 34))
                            .foregroundStyle(DS.Color.accent.opacity(0.4))
                        Text("\(surah.id)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(DS.Color.accent)
                    }
                    .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(surah.nameTurkish)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(DS.Color.textPrimary)
                        Text("\(surah.verseCount) ayet \u{2022} \(surah.revelationType == "Meccan" ? "Mekki" : "Medeni")")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    Spacer()

                    Text(surah.nameArabic)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(DS.Color.textPrimary)
                }
                .padding(.vertical, DS.Space.xs)
            }
            .listRowBackground(DS.Color.backgroundPrimary)
            .listRowSeparator(.hidden)
            .overlay(alignment: .bottom) { Hairline() }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DS.Color.backgroundPrimary)
    }

    // MARK: - Search Results

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

                    VStack(alignment: .leading, spacing: DS.Space.md) {
                        HStack {
                            HStack(spacing: DS.Space.xs) {
                                ZStack {
                                    Image(systemName: "seal.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(DS.Color.accentSoft)
                                    Text("\(verse.verseNumber)")
                                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                                        .foregroundStyle(DS.Color.accent)
                                }
                                Text(verseID)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(DS.Color.accent)
                            }
                            Spacer()
                            Label {
                                Text("Sayfa \(verse.pageNumber)")
                                    .font(.system(size: 11, weight: .regular))
                            } icon: {
                                Image(systemName: "book.pages")
                                    .font(.system(size: 9))
                            }
                            .foregroundStyle(DS.Color.textSecondary)
                        }

                        Text(verse.textArabic)
                            .font(.system(size: 24, weight: .regular))
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(10)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(DS.Color.textPrimary)

                        Text(verse.textTranslation)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(DS.Color.textSecondary)
                            .lineSpacing(4)

                        AccentUnderline(active: isActive)
                    }
                    .padding(.vertical, DS.Space.sm)
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

// MARK: - Reading Mode

enum ReadingMode: String, CaseIterable {
    case arabic = "Arapça"
    case transliteration = "Okunuş"
    case translation = "Meal"
    case all = "Tümü"
}

// MARK: - Surah Detail View (kept for backward compatibility)

struct SurahDetailView: View {
    let surahId: Int
    let container: DependencyContainer

    @State private var verses: [VerseDTO] = []
    @State private var surah: SurahDTO?
    @State private var selectedVerse: VerseDTO?
    @State private var readingMode: ReadingMode = .all

    var body: some View {
        VStack(spacing: 0) {
            Picker("Okuma Modu", selection: $readingMode) {
                ForEach(ReadingMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.sm)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    if let surah {
                        surahHeader(surah)
                            .padding(.bottom, DS.Space.lg)
                    }

                    if let surah, surah.id != 1 && surah.id != 9 {
                        Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(DS.Color.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Space.md)
                            .padding(.bottom, DS.Space.sm)
                    }

                    ForEach(verses) { verse in
                        Button {
                            selectedVerse = verse
                        } label: {
                            verseCard(verse)
                        }
                        .buttonStyle(VerseCardButtonStyle())
                    }
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.bottom, DS.Space.x4)
            }
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle(surah?.nameTurkish ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                verses = try await container.quranRepository.verses(forSurah: surahId)
                let surahs = try await container.quranRepository.allSurahs()
                surah = surahs.first(where: { $0.id == surahId })
            } catch {}
        }
        .sheet(item: $selectedVerse) { verse in
            VerseDetailSheet(verse: verse, surahName: surah?.nameTurkish ?? "")
        }
    }

    private func surahHeader(_ surah: SurahDTO) -> some View {
        VStack(spacing: DS.Space.md) {
            Text(surah.nameArabic)
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(DS.Color.textPrimary)

            Text("\(surah.verseCount) ayet \u{2022} \(surah.revelationType == "Meccan" ? "Mekki" : "Medeni")")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(DS.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DS.Color.surahHeader)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DS.Color.ornamentLine, lineWidth: 0.5)
        )
    }

    private var showTransliteration: Bool {
        readingMode == .transliteration || readingMode == .all
    }

    private var showTranslation: Bool {
        readingMode == .translation || readingMode == .all
    }

    private func verseCard(_ verse: VerseDTO) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack(alignment: .top, spacing: DS.Space.sm) {
                ZStack {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(DS.Color.accentSoft)
                    Text(verse.verseNumber.arabicNumeral)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(DS.Color.accent)
                }
                .frame(width: 28, height: 28)

                Spacer()

                Text(verse.textArabic)
                    .font(.system(size: 24, weight: .regular))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(DS.Color.textPrimary)
                    .lineSpacing(12)
            }

            if showTransliteration && !verse.textTransliteration.isEmpty {
                Text(verse.textTransliteration)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(DS.Color.accent.opacity(0.7))
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if showTranslation && !verse.textTranslation.isEmpty {
                Text(verse.textTranslation)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DS.Color.textSecondary)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, DS.Space.lg)
        .overlay(alignment: .bottom) { Hairline() }
        .animation(.easeOut(duration: 0.2), value: readingMode)
    }
}

// MARK: - Verse Card Button Style

private struct VerseCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? DS.Color.accentSoft : .clear)
                    .padding(.horizontal, -DS.Space.sm)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
