import SwiftUI
import SwiftData

enum QuranSegment: String, CaseIterable {
    case mushaf = "Mushaf"
    case sureler = "Sureler"
}

struct QuranView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: QuranViewModel
    @State private var activeVerseID: String?
    @State private var isImmersive = false
    @State private var lastReadPosition: LastReadPosition?
    @State private var hatimProgress: Double = 0
    @Binding var selectedSegment: QuranSegment
    @Binding var resumePage: Int?
    @Binding var showRehber: Bool
    let container: DependencyContainer

    init(
        container: DependencyContainer,
        selectedSegment: Binding<QuranSegment>,
        resumePage: Binding<Int?> = .constant(nil),
        showRehber: Binding<Bool> = .constant(false)
    ) {
        _viewModel = State(initialValue: QuranViewModel(container: container))
        _selectedSegment = selectedSegment
        _resumePage = resumePage
        _showRehber = showRehber
        self.container = container
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !isImmersive {
                    DSSegmentedControl(
                        QuranSegment.allCases,
                        selected: $selectedSegment,
                        label: { $0.rawValue }
                    )
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
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle(isImmersive ? "" : L10n.Quran.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(isImmersive ? .hidden : .visible, for: .navigationBar)
            .toolbar(isImmersive ? .hidden : .visible, for: .tabBar)
            .searchable(
                text: $viewModel.searchQuery,
                prompt: L10n.Quran.searchPrompt
            )
            .sheet(isPresented: $showRehber) {
                NavigationStack {
                    RehberView(container: container)
                }
            }
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
                loadReadingProgress()
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
        SKNErrorState(
            icon: "externaldrive.badge.exclamationmark",
            message: L10n.Quran.dbMissing
        )
    }

    // MARK: - Surah List (tapping jumps to Mushaf page)

    private var surahList: some View {
        List {
            // Hatim progress + last read card
            surahListHeader
                .listRowBackground(DS.Color.backgroundPrimary)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: DS.Space.sm, leading: DS.Space.lg, bottom: DS.Space.md, trailing: DS.Space.lg))

            // Surah rows
            ForEach(viewModel.surahs) { surah in
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
                            Circle()
                                .fill(DS.Color.accentSoft)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "seal")
                                .font(.system(size: 34))
                                .foregroundStyle(DS.Color.accent.opacity(0.8))
                                .symbolEffect(.pulse, options: .repeating.speed(0.1))
                            
                            Text("\(surah.id)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(DS.Color.accent)
                        }
                        .frame(width: 36, height: 36)
                        .shadow(color: DS.Color.accent.opacity(0.2), radius: 6, y: 3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(surah.nameTurkish)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(DS.Color.textPrimary)
                            
                            HStack(spacing: DS.Space.xs) {
                                Text("\(surah.verseCount) ayet \u{2022} \(L10n.revelationType(surah.revelationType))")
                                    .font(DS.Typography.captionSm)
                                    .foregroundStyle(DS.Color.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                            }
                        }

                        Spacer()

                        Text(surah.nameArabic)
                            .font(DS.Typography.arabicLarge)
                            .foregroundStyle(DS.Color.textPrimary)
                            .shadow(color: DS.Color.textPrimary.opacity(0.1), radius: 2, y: 1)
                    }
                    .padding(.vertical, DS.Space.md)
                    .padding(.horizontal, DS.Space.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                            .fill(DS.Color.cardElevated.opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                            .stroke(DS.Color.glassBorder, lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
                .listRowBackground(DS.Color.backgroundPrimary)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: DS.Space.sm, leading: DS.Space.lg, bottom: DS.Space.sm, trailing: DS.Space.lg))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DS.Color.backgroundPrimary)
    }

    // MARK: - Surah List Header (Hatim Progress + Last Read)

    private var surahListHeader: some View {
        VStack(spacing: DS.Space.md) {
            // Hatim progress card
            VStack(spacing: DS.Space.md) {
                HStack {
                    Label {
                        Text("Hatim")
                            .font(DS.Typography.sectionHead)
                            .tracking(1.5)
                    } icon: {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(DS.Color.accent)

                    Spacer()

                    Text("\(Int(hatimProgress * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(DS.Color.accent)
                }

                DSProgressBar(hatimProgress, height: 6)

                Text(L10n.Common.pagesProgress(Int(hatimProgress * 604), 604))
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(DS.Space.lg)
            .dsGlass(.thin, cornerRadius: DS.Radius.lg)
            .dsShadow(DS.Shadow.premiumCard)

            // Last read card
            if let pos = lastReadPosition {
                Button {
                    viewModel.currentPage = pos.mushafPage
                    selectedSegment = .mushaf
                } label: {
                    HStack(spacing: DS.Space.md) {
                        Image(systemName: "bookmark.fill")
                            .font(DS.Typography.alongSans(size: 14, weight: "Medium"))
                            .foregroundStyle(DS.Color.accent)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                                    .fill(DS.Color.accentSoft)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.Dashboard.whereYouLeft)
                                .font(DS.Typography.alongSans(size: 9, weight: "Bold"))
                                .foregroundStyle(DS.Color.textSecondary)
                                .tracking(1.5)
                            Text(pos.surahNameTurkish)
                                .font(DS.Typography.headline)
                                .foregroundStyle(DS.Color.textPrimary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(L10n.Common.page(pos.mushafPage))
                                .font(DS.Typography.captionSm)
                                .foregroundStyle(DS.Color.textSecondary)
                            Image(systemName: "arrow.right")
                                .font(DS.Typography.trackerLabel)
                                .foregroundStyle(DS.Color.accent)
                        }
                    }
                    .padding(DS.Space.lg)
                    .dsGlass(.regular, cornerRadius: DS.Radius.lg)
                    .dsShadow(DS.Shadow.premiumCard)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Reading Progress Loader

    private func loadReadingProgress() {
        do {
            lastReadPosition = try container.userActivityRepository.getLastReadPosition(context: modelContext)
            let totalPages = try container.userActivityRepository.totalUniquePagesRead(context: modelContext)
            hatimProgress = Double(totalPages) / 604.0
        } catch {
            #if DEBUG
            print("[QuranView] Reading progress load failed: \(error)")
            #endif
        }
    }

    // MARK: - Search Results

    private var searchResultsList: some View {
        Group {
            if viewModel.isSearching {
                DSSkeletonGroup(rows: 4)
            } else if viewModel.searchResults.isEmpty {
                SKNEmptyState(
                    icon: "magnifyingglass",
                    title: L10n.Quran.noResults,
                    message: L10n.Quran.noResultsFor(viewModel.searchQuery)
                )
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
                                    .font(DS.Typography.alongSans(size: 13, weight: "SemiBold"))
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
                            .font(DS.Typography.arabicVerse)
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(DS.Typography.LineSpacing.arabic)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(DS.Color.textPrimary)

                        Text(verse.textTranslation)
                            .font(DS.Typography.footnote)
                            .foregroundStyle(DS.Color.textSecondary)
                            .lineSpacing(DS.Typography.LineSpacing.body)

                        AccentUnderline(active: isActive)
                    }
                    .padding(.vertical, DS.Space.sm)
                    .opacity(activeVerseID == nil || isActive ? 1.0 : 0.6)
                    .animation(DS.Motion.verse, value: activeVerseID)
                    .listRowBackground(DS.Color.backgroundPrimary)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        // Jump to the verse's Mushaf page
                        viewModel.currentPage = verse.pageNumber
                        selectedSegment = .mushaf
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
            DSSegmentedControl(
                ReadingMode.allCases,
                selected: $readingMode,
                label: { $0.rawValue }
            )
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
                            .font(DS.Typography.arabicBismillah)
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
                .font(DS.Typography.arabicHero)
                .foregroundStyle(DS.Color.textPrimary)

            Text("\(surah.verseCount) ayet \u{2022} \(L10n.revelationType(surah.revelationType))")
                .font(DS.Typography.caption)
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
                    .font(DS.Typography.arabicVerse)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(DS.Color.textPrimary)
                    .lineSpacing(DS.Typography.LineSpacing.arabic)
            }

            if showTransliteration && !verse.textTransliteration.isEmpty {
                Text(verse.textTransliteration)
                    .font(DS.Typography.transliteration)
                    .foregroundStyle(DS.Color.accent.opacity(0.7))
                    .lineSpacing(DS.Typography.LineSpacing.transliteration)
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

// MARK: - Preview

#Preview("Quran") {
    struct Preview: View {
        @State private var segment: QuranSegment = .sureler
        var body: some View {
            DSPreview { c in QuranView(container: c, selectedSegment: $segment) }
        }
    }
    return Preview()
}
