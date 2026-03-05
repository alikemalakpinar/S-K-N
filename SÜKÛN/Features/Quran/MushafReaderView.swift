import SwiftUI
import SwiftData

struct MushafReaderView: View {
    @Bindable var viewModel: QuranViewModel
    let container: DependencyContainer
    @Binding var isImmersive: Bool
    @Environment(\.modelContext) private var modelContext

    @State private var showPagePicker = false
    @State private var showTransliteration = true
    @State private var showTranslation = true
    @State private var saveTask: Task<Void, Never>?
    @State private var pageLogTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            DS.Color.backgroundPrimary.ignoresSafeArea()

            // Full-bleed page reader
            TabView(selection: $viewModel.currentPage) {
                ForEach(1...viewModel.totalPages, id: \.self) { page in
                    MushafPageView(pageNumber: page, container: container, preloadedSurahs: viewModel.surahsDict)
                        .tag(page)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .environment(\.showTransliteration, showTransliteration)
            .environment(\.showTranslation, showTranslation)
            .onTapGesture {
                withAnimation(DS.Motion.standard) { isImmersive.toggle() }
            }

            // Floating bottom bar
            if !isImmersive {
                VStack {
                    Spacer()
                    bottomBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showPagePicker) {
            PagePickerSheet(viewModel: viewModel, isPresented: $showPagePicker)
        }
        .onChange(of: viewModel.currentPage) { _, newPage in
            saveTask?.cancel()
            saveTask = Task {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { return }
                await MainActor.run { saveCurrentPosition(page: newPage) }
            }
            pageLogTask?.cancel()
            pageLogTask = Task {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                await MainActor.run { logPageRead(page: newPage) }
            }
        }
    }

    // MARK: - Auto-Save

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
        VStack(spacing: 0) {
            // Toggle row
            HStack(spacing: DS.Space.sm) {
                toggleChip(label: "Okunuş", active: $showTransliteration)
                toggleChip(label: "Meal", active: $showTranslation)

                Spacer()

                // Page info
                Button { showPagePicker = true } label: {
                    HStack(spacing: DS.Space.xs) {
                        Text("Cüz \(viewModel.currentJuzNumber)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(DS.Color.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(DS.Color.accentSoft))

                        Text("\(viewModel.currentPage)/\(viewModel.totalPages)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
                .accessibilityLabel("Sayfa Seç, Sayfa \(viewModel.currentPage), Cüz \(viewModel.currentJuzNumber)")
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.sm)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: -2)
            )
        }
    }

    private func toggleChip(label: String, active: Binding<Bool>) -> some View {
        Button {
            withAnimation(DS.Motion.tap) { active.wrappedValue.toggle() }
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(active.wrappedValue ? .white : DS.Color.textSecondary)
                .padding(.horizontal, DS.Space.md)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(active.wrappedValue ? DS.Color.accent : DS.Color.hairline.opacity(0.5))
                )
        }
        .accessibilityLabel("\(label) \(active.wrappedValue ? "açık" : "kapalı")")
        .accessibilityAddTraits(.isToggle)
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
                    Button("Tamam") { isPresented = false }
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
                        Circle()
                            .fill(DS.Color.accentSoft)
                            .frame(width: 34, height: 34)
                        Text("\(surah.id)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
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
