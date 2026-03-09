import SwiftUI

// MARK: - Environment Keys

private struct ShowTransliterationKey: EnvironmentKey {
    static let defaultValue = false
}

private struct ShowTranslationKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var showTransliteration: Bool {
        get { self[ShowTransliterationKey.self] }
        set { self[ShowTransliterationKey.self] = newValue }
    }
    var showTranslation: Bool {
        get { self[ShowTranslationKey.self] }
        set { self[ShowTranslationKey.self] = newValue }
    }
}

// MARK: - MushafPageView

struct MushafPageView: View {
    let pageNumber: Int
    let container: DependencyContainer
    let preloadedSurahs: [Int: SurahDTO]

    @Environment(\.showTransliteration) private var showTransliteration
    @Environment(\.showTranslation) private var showTranslation
    @Environment(\.dsFontScale) private var fontScale
    @State private var verses: [VerseDTO] = []
    @State private var selectedVerse: VerseDTO?
    @State private var surahs: [Int: SurahDTO] = [:]
    @State private var isLoaded = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: DS.Space.md)

                ForEach(Array(pageContent.enumerated()), id: \.element.id) { index, item in
                    switch item {
                    case .surahHeader(let surah):
                        PremiumSurahHeader(surah: surah)
                            .padding(.horizontal, DS.Space.lg)
                            .padding(.bottom, DS.Space.lg)
                            .padding(.top, index == 0 ? 0 : DS.Space.x2)

                    case .bismillah:
                        bismillahView
                            .padding(.horizontal, DS.Space.x2)
                            .padding(.bottom, DS.Space.md)

                    case .verse(let verse):
                        verseCard(verse)
                            .padding(.horizontal, DS.Space.lg)
                    }
                }

                pageFooter
                    .padding(.top, DS.Space.x2)

                Spacer(minLength: 90)
            }
        }
        .background(DS.Color.backgroundPrimary)
        .opacity(isLoaded ? 1 : 0)
        .animation(.easeIn(duration: 0.25), value: isLoaded)
        .task { await loadPage() }
        .sheet(item: $selectedVerse) { verse in
            VerseDetailSheet(verse: verse, surahName: surahName(for: verse.surahId))
        }
    }

    // MARK: - Page Content

    private enum PageItem: Identifiable {
        case surahHeader(SurahDTO)
        case bismillah(surahId: Int)
        case verse(VerseDTO)

        var id: String {
            switch self {
            case .surahHeader(let s): return "header-\(s.id)"
            case .bismillah(let surahId): return "bismillah-\(surahId)"
            case .verse(let v): return "\(v.surahId):\(v.verseNumber)"
            }
        }
    }

    private var pageContent: [PageItem] {
        var items: [PageItem] = []
        var lastSurahId: Int?

        for verse in verses {
            if verse.verseNumber == 1 && verse.surahId != lastSurahId {
                if let surah = surahs[verse.surahId] {
                    items.append(.surahHeader(surah))
                    if surah.id != 1 && surah.id != 9 {
                        items.append(.bismillah(surahId: surah.id))
                    }
                }
            }
            items.append(.verse(verse))
            lastSurahId = verse.surahId
        }
        return items
    }

    // MARK: - Bismillah

    private var bismillahView: some View {
        VStack(spacing: DS.Space.sm) {
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.system(size: 24 * fontScale, weight: .regular))
                .foregroundStyle(DS.Color.textPrimary)
                .frame(maxWidth: .infinity)

            Text("Rahmân ve Rahîm olan Allah'ın adıyla")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(DS.Color.textSecondary)
        }
        .padding(.vertical, DS.Space.md)
    }

    // MARK: - Verse Card

    private func verseCard(_ verse: VerseDTO) -> some View {
        Button { selectedVerse = verse } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Verse number badge
                HStack(alignment: .center, spacing: DS.Space.sm) {
                    ZStack {
                        Circle()
                            .fill(DS.Color.accent)
                            .frame(width: 32, height: 32)
                        Text("\(verse.verseNumber)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding(.bottom, DS.Space.sm)

                // Arabic text — larger with better line spacing
                let baseSize: CGFloat = showTransliteration || showTranslation ? 24 : 28
                Text(verse.textArabic)
                    .font(.system(size: baseSize * fontScale, weight: .regular))
                    .foregroundStyle(DS.Color.textPrimary)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(showTransliteration || showTranslation ? 14 : 20)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                // Transliteration — clear, readable serif
                if showTransliteration && !verse.textTransliteration.isEmpty {
                    Text(verse.textTransliteration)
                        .font(.system(size: 15 * fontScale, weight: .regular, design: .serif))
                        .italic()
                        .foregroundStyle(DS.Color.accent.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, DS.Space.md)
                }

                // Translation — clean body text
                if showTranslation && !verse.textTranslation.isEmpty {
                    Text(verse.textTranslation)
                        .font(.system(size: 15 * fontScale, weight: .regular))
                        .foregroundStyle(DS.Color.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, DS.Space.sm)
                }
            }
            .padding(DS.Space.lg)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DS.Color.cardElevated)
                    .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
            )
            .padding(.bottom, DS.Space.sm)
        }
        .buttonStyle(VerseCardStyle())
    }

    // MARK: - Page Footer

    private var pageFooter: some View {
        HStack(spacing: DS.Space.sm) {
            Rectangle()
                .fill(DS.Color.hairline)
                .frame(width: 30, height: 0.5)

            Text("\(pageNumber)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(DS.Color.textSecondary)

            Rectangle()
                .fill(DS.Color.hairline)
                .frame(width: 30, height: 0.5)
        }
    }

    // MARK: - Helpers

    private func loadPage() async {
        do {
            verses = try await container.quranRepository.versesForPage(page: pageNumber)
            if !preloadedSurahs.isEmpty {
                surahs = preloadedSurahs
            } else {
                let allSurahs = try await container.quranRepository.allSurahs()
                for s in allSurahs { surahs[s.id] = s }
            }
            isLoaded = true
        } catch {
            isLoaded = true
            #if DEBUG
            print("[MushafPage] Load failed for page \(pageNumber): \(error)")
            #endif
        }
    }

    private func surahName(for id: Int) -> String {
        surahs[id]?.nameTurkish ?? "\(id)"
    }
}

// MARK: - Verse Card Style

private struct VerseCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Premium Surah Header

private struct PremiumSurahHeader: View {
    let surah: SurahDTO

    var body: some View {
        VStack(spacing: DS.Space.md) {
            Text(surah.nameArabic)
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(.white)

            Text(surah.nameTurkish)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
                .tracking(1)

            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(width: 40, height: 1)

            HStack(spacing: DS.Space.md) {
                Text(surah.revelationType == "Meccan" ? "Mekki" : "Medeni")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                Circle()
                    .fill(.white.opacity(0.4))
                    .frame(width: 3, height: 3)
                Text("\(surah.verseCount) ayet")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.x2)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.25, green: 0.22, blue: 0.50),
                            Color(red: 0.35, green: 0.30, blue: 0.58),
                            Color(red: 0.45, green: 0.38, blue: 0.65)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 0.30, green: 0.25, blue: 0.55).opacity(0.3), radius: 12, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.08), lineWidth: 0.5)
        )
    }
}

// MARK: - Arabic Numeral Helper

extension Int {
    var arabicNumeral: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
