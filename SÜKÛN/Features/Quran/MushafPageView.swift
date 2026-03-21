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
    @Environment(\.readingTheme) private var theme
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
                        SKNSurahHeader(surah: surah)
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
        .background(theme.background)
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

    // MARK: - Ornamental Bismillah

    private var bismillahView: some View {
        VStack(spacing: DS.Space.md) {
            // Top ornament
            HStack(spacing: DS.Space.md) {
                Rectangle()
                    .fill(theme.accent.opacity(0.2))
                    .frame(height: 0.5)
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundStyle(theme.accent.opacity(0.4))
                Rectangle()
                    .fill(theme.accent.opacity(0.2))
                    .frame(height: 0.5)
            }

            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(DS.Typography.arabicBismillah)
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity)

            Text(L10n.Quran.bismillahTranslation)
                .font(DS.Typography.cormorant(size: 13, weight: "Italic"))
                .foregroundStyle(theme.textSecondary)

            // Bottom ornament
            HStack(spacing: DS.Space.md) {
                Rectangle()
                    .fill(theme.accent.opacity(0.2))
                    .frame(height: 0.5)
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundStyle(theme.accent.opacity(0.4))
                Rectangle()
                    .fill(theme.accent.opacity(0.2))
                    .frame(height: 0.5)
            }
        }
        .padding(.vertical, DS.Space.lg)
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Verse Card

    private func verseCard(_ verse: VerseDTO) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Verse number badge
            HStack(alignment: .center, spacing: DS.Space.sm) {
                ZStack {
                    Circle()
                        .fill(theme.accent)
                        .frame(width: 32, height: 32)
                    Text("\(verse.verseNumber)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding(.bottom, DS.Space.sm)

            // Arabic text
            let baseSize: CGFloat = showTransliteration || showTranslation ? 24 : 28
            Text(verse.textArabic)
                .font(DS.Typography.arabicUthmanic(size: baseSize * fontScale))
                .foregroundStyle(theme.textPrimary)
                .multilineTextAlignment(.trailing)
                .lineSpacing(showTransliteration || showTranslation ? 14 : 20)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .trailing)

            // Transliteration
            if showTransliteration && !verse.textTransliteration.isEmpty {
                Text(verse.textTransliteration)
                    .font(DS.Typography.cormorant(size: 15 * fontScale, weight: "Italic"))
                    .foregroundStyle(theme.accent.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DS.Space.md)
            }

            // Translation
            if showTranslation && !verse.textTranslation.isEmpty {
                Text(verse.textTranslation)
                    .font(.system(size: 15 * fontScale, weight: .regular))
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DS.Space.sm)
            }
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(theme.cardFill)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
        .padding(.bottom, DS.Space.sm)
        .contentShape(Rectangle())   // Ensure full card is tappable (44pt minimum)
        .onTapGesture {
            DS.Haptic.softTap()
            selectedVerse = verse
        }
        .onLongPressGesture(minimumDuration: 0.4) {
            DS.Haptic.snap()
            selectedVerse = verse
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.Quran.verseAccessibility(verse.verseNumber, translation: verse.textTranslation))
        .accessibilityHint(L10n.Quran.tapToDetail)
    }

    // MARK: - Page Footer

    private var pageFooter: some View {
        HStack(spacing: DS.Space.sm) {
            Rectangle()
                .fill(theme.hairline)
                .frame(width: 30, height: 0.5)

            Text("\(pageNumber)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary)

            Rectangle()
                .fill(theme.hairline)
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

// MARK: - SKNSurahHeader (Reusable)

struct SKNSurahHeader: View {
    let surah: SurahDTO
    @Environment(\.readingTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: DS.Space.md) {
            Text(surah.nameArabic)
                .font(DS.Typography.arabicDisplay)
                .foregroundStyle(DS.Color.textPrimary)
                .accessibilityLabel(surah.nameTurkish)

            Text(surah.nameTurkish)
                .font(DS.Typography.displayBody)
                .foregroundStyle(DS.Color.textSecondary)

            Rectangle()
                .fill(DS.Color.accent.opacity(0.3))
                .frame(width: 40, height: 1)

            HStack(spacing: DS.Space.md) {
                Text(L10n.revelationType(surah.revelationType))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DS.Color.textSecondary)
                Circle()
                    .fill(DS.Color.accent.opacity(0.5))
                    .frame(width: 3, height: 3)
                Text("\(surah.verseCount) ayet")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.x2)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DS.Color.accentSoft,
                            DS.Color.accentSoft.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: DS.Color.accent.opacity(0.08), radius: 12, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .stroke(DS.Color.accent.opacity(0.12), lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(surah.nameTurkish), \(L10n.Common.ayetCount(surah.verseCount)), \(L10n.revelationType(surah.revelationType))")
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
