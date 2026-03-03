import SwiftUI

struct MushafPageView: View {
    let pageNumber: Int
    let container: DependencyContainer

    @State private var verses: [VerseDTO] = []
    @State private var selectedVerse: VerseDTO?
    @State private var surahs: [Int: SurahDTO] = [:]
    @State private var isLoaded = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: DS.Space.lg)

                // Build page content with interleaved surah headers
                ForEach(pageContent, id: \.id) { item in
                    switch item {
                    case .surahHeader(let surah):
                        SurahOrnamentHeader(surah: surah)
                            .padding(.horizontal, DS.Space.md)
                            .padding(.bottom, DS.Space.lg)
                            .padding(.top, DS.Space.sm)

                    case .bismillah:
                        bismillahView
                            .padding(.bottom, DS.Space.lg)

                    case .verse(let verse):
                        verseRow(verse)
                    }
                }

                // Page number at bottom
                Text(pageNumber.arabicNumeral)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(DS.Color.textSecondary.opacity(0.5))
                    .padding(.top, DS.Space.xl)

                Spacer(minLength: DS.Space.x4)
            }
            .padding(.horizontal, DS.Space.lg)
        }
        .background(DS.Color.quranCard)
        .opacity(isLoaded ? 1 : 0)
        .animation(.easeIn(duration: 0.2), value: isLoaded)
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

    // MARK: - Page Content Model

    private enum PageItem: Identifiable {
        case surahHeader(SurahDTO)
        case bismillah
        case verse(VerseDTO)

        var id: String {
            switch self {
            case .surahHeader(let s): return "header-\(s.id)"
            case .bismillah: return "bismillah-\(UUID().uuidString)"
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
                        items.append(.bismillah)
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
            OrnamentalDivider()
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(DS.Typography.arabicLarge)
                .foregroundStyle(DS.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Space.xs)
            OrnamentalDivider()
        }
    }

    // MARK: - Verse Row

    private func verseRow(_ verse: VerseDTO) -> some View {
        Button {
            selectedVerse = verse
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: DS.Space.sm) {
                Spacer(minLength: 0)

                // Arabic text — large, readable
                Text(verse.textArabic)
                    .font(DS.Typography.arabicHero)
                    .foregroundStyle(DS.Color.textPrimary)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(20)
                    .fixedSize(horizontal: false, vertical: true)

                // Verse number ornament
                VerseNumberOrnament(number: verse.verseNumber)
            }
            .padding(.vertical, DS.Space.sm)
        }
        .buttonStyle(VerseButtonStyle())
    }

    // MARK: - Helpers

    private func loadPage() async {
        do {
            verses = try await container.quranRepository.versesForPage(page: pageNumber)
            let allSurahs = try await container.quranRepository.allSurahs()
            for s in allSurahs {
                surahs[s.id] = s
            }
            isLoaded = true
        } catch {
            isLoaded = true
        }
    }

    private func surahName(for id: Int) -> String {
        surahs[id]?.nameTurkish ?? "\(id)"
    }
}

// MARK: - Verse Button Style

private struct VerseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(configuration.isPressed ? DS.Color.accentSoft : .clear)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Verse Number Ornament

private struct VerseNumberOrnament: View {
    let number: Int

    var body: some View {
        ZStack {
            // Octagonal star ornament
            Image(systemName: "seal.fill")
                .font(.system(size: 30))
                .foregroundStyle(DS.Color.accent.opacity(0.12))

            Image(systemName: "seal")
                .font(.system(size: 30))
                .foregroundStyle(DS.Color.accent.opacity(0.45))

            Text(number.arabicNumeral)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DS.Color.accent)
        }
        .frame(width: 34, height: 34)
    }
}

// MARK: - Surah Ornament Header

private struct SurahOrnamentHeader: View {
    let surah: SurahDTO

    var body: some View {
        VStack(spacing: 0) {
            // Ornamental top line
            OrnamentalDivider()
                .padding(.bottom, DS.Space.sm)

            // Header card
            VStack(spacing: DS.Space.sm) {
                // Arabic name prominent
                Text(surah.nameArabic)
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(DS.Color.textPrimary)

                // Turkish name + info
                Text(surah.nameTurkish)
                    .font(DS.Typography.surahTitle)
                    .foregroundStyle(DS.Color.textPrimary)

                HStack(spacing: DS.Space.sm) {
                    Text("\(surah.verseCount) ayet")
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.textSecondary)

                    Circle()
                        .fill(DS.Color.textSecondary.opacity(0.4))
                        .frame(width: 3, height: 3)

                    Text(surah.revelationType == "Meccan" ? "Mekki" : "Medeni")
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.textSecondary)

                    Circle()
                        .fill(DS.Color.textSecondary.opacity(0.4))
                        .frame(width: 3, height: 3)

                    Text("Sıra: \(surah.id)")
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.lg)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(DS.Color.surahHeader)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(DS.Color.ornamentLine, lineWidth: 0.5)
            )

            // Ornamental bottom line
            OrnamentalDivider()
                .padding(.top, DS.Space.sm)
        }
    }
}

// MARK: - Ornamental Divider

private struct OrnamentalDivider: View {
    var body: some View {
        HStack(spacing: DS.Space.sm) {
            gradientLine
            // Center diamond ornament
            Image(systemName: "diamond.fill")
                .font(.system(size: 5))
                .foregroundStyle(DS.Color.accent.opacity(0.5))
            Image(systemName: "diamond.fill")
                .font(.system(size: 7))
                .foregroundStyle(DS.Color.accent.opacity(0.7))
            Image(systemName: "diamond.fill")
                .font(.system(size: 5))
                .foregroundStyle(DS.Color.accent.opacity(0.5))
            gradientLine
        }
        .frame(height: 8)
    }

    private var gradientLine: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [DS.Color.ornamentLine.opacity(0), DS.Color.ornamentLine, DS.Color.ornamentLine.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 0.5)
    }
}

// MARK: - Rotated Star Shape (for surah number badge)

private struct RotatedStar: Shape {
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
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
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
