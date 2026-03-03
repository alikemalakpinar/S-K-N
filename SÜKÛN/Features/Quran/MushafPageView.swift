import SwiftUI

struct MushafPageView: View {
    let pageNumber: Int
    let container: DependencyContainer

    @State private var verses: [VerseDTO] = []
    @State private var selectedVerse: VerseDTO?
    @State private var surahs: [Int: SurahDTO] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Surah header(s) if a new surah starts on this page
                let surahStarts = findSurahStarts()
                if !surahStarts.isEmpty {
                    ForEach(surahStarts, id: \.id) { surah in
                        surahHeader(surah)
                    }
                }

                // Verses
                WrappingVerseLayout(verses: verses) { verse in
                    verseButton(verse)
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.md)

                Spacer(minLength: DS.Space.x4)

                // Page number
                Text("\(pageNumber)")
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textSecondary)
                    .padding(.bottom, DS.Space.md)
            }
        }
        .background(DS.Color.backgroundPrimary)
        .task {
            await loadPage()
        }
        .sheet(item: $selectedVerse) { verse in
            VerseDetailSheet(
                verse: verse,
                surahName: surahName(for: verse.surahId)
            )
        }
    }

    // MARK: - Subviews

    private func surahHeader(_ surah: SurahDTO) -> some View {
        VStack(spacing: DS.Space.sm) {
            Hairline()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(surah.nameTurkish)
                        .font(DS.Typography.sectionHead)
                        .foregroundStyle(DS.Color.accent)
                    Text("\(surah.verseCount) ayet")
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.textSecondary)
                }
                Spacer()
                Text(surah.nameArabic)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(DS.Color.textPrimary)
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.sm)

            // Bismillah (except for Surah 1 and 9)
            if surah.id != 1 && surah.id != 9 {
                Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(DS.Color.textPrimary)
                    .padding(.bottom, DS.Space.sm)
            }
            Hairline()
        }
    }

    private func verseButton(_ verse: VerseDTO) -> some View {
        Button {
            selectedVerse = verse
        } label: {
            HStack(alignment: .top, spacing: 2) {
                Text(verse.textArabic)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(DS.Color.textPrimary)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(10)

                // Verse number marker
                Text("﴿\(verse.verseNumber.arabicNumeral)﴾")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DS.Color.accent)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func loadPage() async {
        do {
            verses = try await container.quranRepository.versesForPage(page: pageNumber)
            // Load surah metadata for any surah that starts on this page
            let allSurahs = try await container.quranRepository.allSurahs()
            for s in allSurahs {
                surahs[s.id] = s
            }
        } catch {
            // Silent fail for individual page loads
        }
    }

    private func findSurahStarts() -> [SurahDTO] {
        var starts: [SurahDTO] = []
        var seen = Set<Int>()
        for verse in verses {
            if verse.verseNumber == 1 && !seen.contains(verse.surahId) {
                seen.insert(verse.surahId)
                if let surah = surahs[verse.surahId] {
                    starts.append(surah)
                }
            }
        }
        return starts
    }

    private func surahName(for id: Int) -> String {
        surahs[id]?.nameTurkish ?? "\(id)"
    }
}

// MARK: - Wrapping Verse Layout

private struct WrappingVerseLayout<Content: View>: View {
    let verses: [VerseDTO]
    let content: (VerseDTO) -> Content

    var body: some View {
        // Right-to-left flowing text layout
        VStack(alignment: .trailing, spacing: DS.Space.sm) {
            ForEach(verses) { verse in
                content(verse)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Arabic Numeral Helper

private extension Int {
    var arabicNumeral: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
