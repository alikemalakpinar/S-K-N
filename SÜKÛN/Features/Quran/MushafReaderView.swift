import SwiftUI
import SwiftData

// MARK: - Reading Theme

enum ReadingTheme: String, CaseIterable, Identifiable {
    case light = "Açık"
    case dark = "Koyu"
    case sepia = "Sepia"

    var id: String { rawValue }

    var background: Color {
        switch self {
        case .light: return Color(hex: 0xFFFEFB)
        case .dark:  return Color(hex: 0x1A1A1E)
        case .sepia: return Color(hex: 0xF5EDDC)
        }
    }

    var textPrimary: Color {
        switch self {
        case .light: return Color(hex: 0x1A1A1C)
        case .dark:  return Color(hex: 0xF0EDE7)
        case .sepia: return Color(hex: 0x3A3020)
        }
    }

    var textSecondary: Color {
        switch self {
        case .light: return Color(hex: 0x88857E)
        case .dark:  return Color(hex: 0x8C8A85)
        case .sepia: return Color(hex: 0x7A6E58)
        }
    }

    var accent: Color {
        switch self {
        case .light: return DS.Color.accent
        case .dark:  return Color(hex: 0xC8A558)
        case .sepia: return Color(hex: 0x9A7A3A)
        }
    }

    var cardFill: Color {
        switch self {
        case .light: return .white
        case .dark:  return Color(hex: 0x222228)
        case .sepia: return Color(hex: 0xFAF2E4)
        }
    }

    var hairline: Color {
        switch self {
        case .light: return Color(hex: 0xEBE9E3)
        case .dark:  return Color(hex: 0x2A2C30)
        case .sepia: return Color(hex: 0xE0D5BE)
        }
    }

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark:  return "moon.fill"
        case .sepia: return "book.fill"
        }
    }
}

// MARK: - Reading Theme Environment Key

struct ReadingThemeKey: EnvironmentKey {
    static let defaultValue: ReadingTheme = .light
}

extension EnvironmentValues {
    var readingTheme: ReadingTheme {
        get { self[ReadingThemeKey.self] }
        set { self[ReadingThemeKey.self] = newValue }
    }
}

// MARK: - MushafReaderView

struct MushafReaderView: View {
    @Bindable var viewModel: QuranViewModel
    let container: DependencyContainer
    @Binding var isImmersive: Bool
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showPagePicker = false
    @State private var showReadingSettings = false
    @State private var showTransliteration = true
    @State private var showTranslation = true
    @State private var readingTheme: ReadingTheme = .light
    @State private var arabicFontScale: Double = 1.0
    @State private var saveTask: Task<Void, Never>?
    @State private var pageLogTask: Task<Void, Never>?
    @State private var didLoadPrefs = false

    var body: some View {
        ZStack {
            // Theme-aware background
            readingTheme.background
                .ignoresSafeArea()
                .animation(reduceMotion ? nil : DS.Motion.standard, value: readingTheme)

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
            .environment(\.readingTheme, readingTheme)
            .environment(\.dsFontScale, arabicFontScale)
            .onTapGesture {
                withAnimation(reduceMotion ? nil : DS.Motion.standard) { isImmersive.toggle() }
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
        .sheet(isPresented: $showReadingSettings) {
            SKNReadingSettingsSheet(
                theme: $readingTheme,
                fontScale: $arabicFontScale,
                showTransliteration: $showTransliteration,
                showTranslation: $showTranslation
            )
        }
        .onChange(of: viewModel.currentPage) { _, newPage in
            DS.Haptic.pageTurn()

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
        // Persist reading prefs on change
        .onChange(of: showTransliteration) { _, _ in persistReadingPrefs() }
        .onChange(of: showTranslation) { _, _ in persistReadingPrefs() }
        .onChange(of: readingTheme) { _, _ in persistReadingPrefs() }
        .onChange(of: arabicFontScale) { _, _ in persistReadingPrefs() }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            loadReadingPrefs()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: - Preference Persistence

    private func loadReadingPrefs() {
        guard !didLoadPrefs else { return }
        didLoadPrefs = true
        let descriptor = FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" })
        if let settings = try? modelContext.fetch(descriptor).first {
            showTransliteration = settings.showTransliteration
            showTranslation = settings.showTranslation
            readingTheme = ReadingTheme(rawValue: settings.quranReadingTheme) ?? .light
            arabicFontScale = settings.quranFontScale
        }
    }

    private func persistReadingPrefs() {
        guard didLoadPrefs else { return }
        let descriptor = FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" })
        if let settings = try? modelContext.fetch(descriptor).first {
            settings.showTransliteration = showTransliteration
            settings.showTranslation = showTranslation
            settings.quranReadingTheme = readingTheme.rawValue
            settings.quranFontScale = arabicFontScale
            try? modelContext.save()
        }
    }

    // MARK: - Auto-Save

    private func saveCurrentPosition(page: Int) {
        Task {
            // Load fresh verse data for the displayed page
            // (viewModel.pageVerses may be stale if user swiped rapidly)
            await viewModel.loadPage(page)
            await MainActor.run {
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
        }
    }

    private func logPageRead(page: Int) {
        try? container.userActivityRepository.logPageRead(page: page, context: modelContext)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: DS.Space.sm) {
                toggleChip(label: "Okunuş", active: $showTransliteration)
                toggleChip(label: "Meal", active: $showTranslation)

                Spacer()

                // Reading settings button
                Button {
                    DS.Haptic.softTap()
                    showReadingSettings = true
                } label: {
                    Image(systemName: "textformat.size")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DS.Color.accent)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle().fill(DS.Color.accentSoft)
                        )
                }
                .accessibilityLabel("Okuma Ayarları")

                // Page info
                Button {
                    DS.Haptic.softTap()
                    showPagePicker = true
                } label: {
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
                .frame(minHeight: 44)   // Accessibility: 44pt minimum
                .accessibilityLabel("Sayfa Seç, Sayfa \(viewModel.currentPage), Cüz \(viewModel.currentJuzNumber)")
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.xs)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: -2)
            )
        }
    }

    private func toggleChip(label: String, active: Binding<Bool>) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : DS.Motion.tap) { active.wrappedValue.toggle() }
            DS.Haptic.selection()
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(active.wrappedValue ? .white : DS.Color.textSecondary)
                .padding(.horizontal, DS.Space.md)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(active.wrappedValue ? DS.Color.accent : DS.Color.hairline.opacity(0.5))
                )
        }
        .frame(minHeight: 44)   // Accessibility: 44pt minimum
        .accessibilityLabel("\(label) \(active.wrappedValue ? "açık" : "kapalı")")
        .accessibilityAddTraits(.isToggle)
    }
}

// MARK: - SKNReadingSettingsSheet (Reusable)

struct SKNReadingSettingsSheet: View {
    @Binding var theme: ReadingTheme
    @Binding var fontScale: Double
    @Binding var showTransliteration: Bool
    @Binding var showTranslation: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Space.x2) {
                // Theme selection
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    Text("TEMA")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(DS.Color.textSecondary)
                        .tracking(2)

                    HStack(spacing: DS.Space.md) {
                        ForEach(ReadingTheme.allCases) { t in
                            Button {
                                withAnimation(DS.Motion.tap) { theme = t }
                                DS.Haptic.selection()
                            } label: {
                                VStack(spacing: DS.Space.sm) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(t.background)
                                        .frame(height: 60)
                                        .overlay(
                                            Text("بسم")
                                                .font(.system(size: 20))
                                                .foregroundStyle(t.textPrimary)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(theme == t ? DS.Color.accent : DS.Color.hairline, lineWidth: theme == t ? 2 : 0.5)
                                        )

                                    Text(t.rawValue)
                                        .font(.system(size: 12, weight: theme == t ? .bold : .medium))
                                        .foregroundStyle(theme == t ? DS.Color.accent : DS.Color.textSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(t.rawValue) tema")
                            .accessibilityAddTraits(theme == t ? .isSelected : [])
                        }
                    }
                }

                // Font size slider
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    HStack {
                        Text("YAZI BOYUTU")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(DS.Color.textSecondary)
                            .tracking(2)
                        Spacer()
                        Text("\(Int(fontScale * 100))%")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(DS.Color.accent)
                    }

                    HStack(spacing: DS.Space.md) {
                        Image(systemName: "textformat.size.smaller")
                            .font(.system(size: 12))
                            .foregroundStyle(DS.Color.textSecondary)

                        Slider(value: $fontScale, in: 0.7...1.5, step: 0.05)
                            .tint(DS.Color.accent)
                            .accessibilityLabel("Yazı boyutu")
                            .accessibilityValue("Yüzde \(Int(fontScale * 100))")

                        Image(systemName: "textformat.size.larger")
                            .font(.system(size: 16))
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    // Preview
                    Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                        .font(.system(size: 24 * fontScale, weight: .regular))
                        .foregroundStyle(DS.Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Space.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(DS.Color.backgroundSecondary)
                        )
                }

                // Content toggles
                VStack(spacing: DS.Space.md) {
                    Toggle(isOn: $showTransliteration) {
                        Label {
                            Text("Okunuş")
                                .font(.system(size: 15, weight: .medium))
                        } icon: {
                            Image(systemName: "text.word.spacing")
                                .font(.system(size: 13))
                                .foregroundStyle(DS.Color.accent)
                        }
                    }
                    .tint(DS.Color.accent)

                    Toggle(isOn: $showTranslation) {
                        Label {
                            Text("Meal")
                                .font(.system(size: 15, weight: .medium))
                        } icon: {
                            Image(systemName: "text.book.closed")
                                .font(.system(size: 13))
                                .foregroundStyle(DS.Color.accent)
                        }
                    }
                    .tint(DS.Color.accent)
                }

                Spacer()
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.top, DS.Space.lg)
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Okuma Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") { dismiss() }
                        .foregroundStyle(DS.Color.accent)
                        .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
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
