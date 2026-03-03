import SwiftUI
import SwiftData

struct MushafReaderView: View {
    @Bindable var viewModel: QuranViewModel
    let container: DependencyContainer
    @Binding var isImmersive: Bool
    @Environment(\.modelContext) private var modelContext

    @State private var showPagePicker = false
    @State private var showTransliteration = false
    @State private var saveTask: Task<Void, Never>?
    @State private var pageLogTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            // Full-bleed page reader
            TabView(selection: $viewModel.currentPage) {
                ForEach(1...viewModel.totalPages, id: \.self) { page in
                    MushafPageView(pageNumber: page, container: container)
                        .tag(page)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .environment(\.showTransliteration, showTransliteration)
            .onTapGesture {
                withAnimation(DS.Motion.standard) {
                    isImmersive.toggle()
                }
            }

            // Floating bottom bar — hides in immersive mode
            if !isImmersive {
                VStack {
                    Spacer()
                    bottomBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(DS.Color.quranCard)
        .sheet(isPresented: $showPagePicker) {
            PagePickerSheet(
                viewModel: viewModel,
                isPresented: $showPagePicker
            )
        }
        .onChange(of: viewModel.currentPage) { _, newPage in
            // Debounce 2s — save last read position
            saveTask?.cancel()
            saveTask = Task {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { return }
                await MainActor.run { saveCurrentPosition(page: newPage) }
            }

            // Log page read after 3s viewing
            pageLogTask?.cancel()
            pageLogTask = Task {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                await MainActor.run { logPageRead(page: newPage) }
            }
        }
    }

    // MARK: - Auto-Save Helpers

    private func saveCurrentPosition(page: Int) {
        let surahInfo = viewModel.surahInfoForCurrentPage()
        let firstVerse = viewModel.pageVerses.first
        try? container.userActivityRepository.saveLastReadPosition(
            page: page,
            surahId: surahInfo?.id ?? firstVerse?.surahId ?? 1,
            verseNumber: firstVerse?.verseNumber ?? 1,
            surahName: surahInfo?.name ?? "",
            context: modelContext
        )
    }

    private func logPageRead(page: Int) {
        try? container.userActivityRepository.logPageRead(page: page, context: modelContext)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: DS.Space.md) {
            // Transliteration toggle
            Button {
                withAnimation(DS.Motion.tap) {
                    showTransliteration.toggle()
                }
            } label: {
                Image(systemName: showTransliteration ? "text.word.spacing" : "textformat.alt")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(showTransliteration ? DS.Color.accent : DS.Color.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(showTransliteration ? DS.Color.accentSoft : .clear)
                    )
            }

            // Page info button
            Button {
                showPagePicker = true
            } label: {
                HStack(spacing: DS.Space.md) {
                    // Juz indicator
                    Text("Cüz \(viewModel.currentJuzNumber)")
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.accent)
                        .padding(.horizontal, DS.Space.sm)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(DS.Color.accentSoft)
                        )

                    // Page number
                    HStack(spacing: 4) {
                        Image(systemName: "book.pages")
                            .font(.system(size: 10, weight: .medium))
                        Text("\(viewModel.currentPage)")
                            .font(DS.Typography.pageNumber)
                    }
                    .foregroundStyle(DS.Color.textSecondary)

                    // Divider dot
                    Circle()
                        .fill(DS.Color.textSecondary.opacity(0.3))
                        .frame(width: 3, height: 3)

                    // Total pages
                    Text("/ \(viewModel.totalPages)")
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.textSecondary.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.vertical, DS.Space.sm)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        )
        .padding(.bottom, DS.Space.sm)
    }
}

// MARK: - Page Picker Sheet

private struct PagePickerSheet: View {
    @Bindable var viewModel: QuranViewModel
    @Binding var isPresented: Bool
    @State private var searchText = ""

    private var filteredSurahs: [SurahDTO] {
        if searchText.isEmpty { return viewModel.surahs }
        let q = searchText.lowercased()
        return viewModel.surahs.filter {
            $0.nameTurkish.lowercased().contains(q) ||
            $0.nameArabic.contains(q) ||
            $0.nameEnglish.lowercased().contains(q) ||
            "\($0.id)" == q
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                pageSliderSection
                    .padding(.top, DS.Space.lg)

                Hairline()
                    .padding(.vertical, DS.Space.sm)

                surahListSection
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Sayfa Seç")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Sure ara...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") {
                        isPresented = false
                    }
                    .foregroundStyle(DS.Color.accent)
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var pageSliderSection: some View {
        VStack(spacing: DS.Space.md) {
            HStack(alignment: .firstTextBaseline, spacing: DS.Space.xs) {
                Text("\(viewModel.currentPage)")
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .foregroundStyle(DS.Color.accent)
                Text("/ \(viewModel.totalPages)")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(DS.Color.textSecondary)
            }

            Text("Cüz \(viewModel.currentJuzNumber)")
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Color.textSecondary)

            Slider(
                value: Binding(
                    get: { Double(viewModel.currentPage) },
                    set: { viewModel.currentPage = Int($0) }
                ),
                in: 1...Double(viewModel.totalPages),
                step: 1
            )
            .tint(DS.Color.accent)
            .padding(.horizontal, DS.Space.lg)
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.bottom, DS.Space.md)
    }

    private var surahListSection: some View {
        List(filteredSurahs) { surah in
            Button {
                Task {
                    let page = await viewModel.jumpToSurah(surah.id)
                    viewModel.currentPage = page
                    isPresented = false
                }
            } label: {
                HStack(spacing: DS.Space.md) {
                    ZStack {
                        RotatedStarSmall()
                            .fill(DS.Color.accentSoft)
                            .frame(width: 32, height: 32)
                        RotatedStarSmall()
                            .stroke(DS.Color.accent.opacity(0.3), lineWidth: 0.5)
                            .frame(width: 32, height: 32)
                        Text("\(surah.id)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(DS.Color.accent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(surah.nameTurkish)
                            .font(.system(size: 16, weight: .medium))
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
                .padding(.vertical, DS.Space.xs)
            }
            .listRowBackground(DS.Color.backgroundPrimary)
            .listRowSeparator(.hidden)
            .overlay(alignment: .bottom) { Hairline() }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Small Rotated Star (for page picker)

private struct RotatedStarSmall: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.65
        let points = 8
        var path = Path()
        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
