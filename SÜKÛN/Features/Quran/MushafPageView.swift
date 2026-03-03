import SwiftUI

// MARK: - Transliteration Environment Key

private struct ShowTransliterationKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var showTransliteration: Bool {
        get { self[ShowTransliterationKey.self] }
        set { self[ShowTransliterationKey.self] = newValue }
    }
}

struct MushafPageView: View {
    let pageNumber: Int
    let container: DependencyContainer

    @Environment(\.showTransliteration) private var showTransliteration
    @State private var verses: [VerseDTO] = []
    @State private var selectedVerse: VerseDTO?
    @State private var surahs: [Int: SurahDTO] = [:]
    @State private var isLoaded = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: DS.Space.xl)

                // Build page content with interleaved surah headers
                ForEach(Array(pageContent.enumerated()), id: \.element.id) { index, item in
                    switch item {
                    case .surahHeader(let surah):
                        SurahOrnamentHeader(surah: surah)
                            .padding(.horizontal, DS.Space.sm)
                            .padding(.bottom, DS.Space.md)
                            .padding(.top, index == 0 ? 0 : DS.Space.xl)

                    case .bismillah:
                        bismillahView
                            .padding(.horizontal, DS.Space.md)
                            .padding(.bottom, DS.Space.md)

                    case .verse(let verse, let isLast):
                        verseRow(verse, isLast: isLast)
                    }
                }

                // Page number ornament at bottom
                pageNumberFooter
                    .padding(.top, DS.Space.x2)

                Spacer(minLength: DS.Space.x4)
            }
            .padding(.horizontal, DS.Space.md)
        }
        // Page frame
        .overlay(pageFrame)
        .background(DS.Color.quranCard)
        .opacity(isLoaded ? 1 : 0)
        .animation(.easeIn(duration: 0.3), value: isLoaded)
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

    // MARK: - Page Frame (mushaf border)

    private var pageFrame: some View {
        GeometryReader { geo in
            let inset: CGFloat = 6
            RoundedRectangle(cornerRadius: 2)
                .stroke(DS.Color.ornamentLine.opacity(0.35), lineWidth: 0.5)
                .padding(inset)
                .overlay {
                    // Double-line frame effect
                    RoundedRectangle(cornerRadius: 1)
                        .stroke(DS.Color.ornamentLine.opacity(0.15), lineWidth: 0.5)
                        .padding(inset + 4)
                }
                .allowsHitTesting(false)
        }
    }

    // MARK: - Page Number Footer

    private var pageNumberFooter: some View {
        HStack(spacing: DS.Space.sm) {
            // Left decorative line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [DS.Color.ornamentLine.opacity(0), DS.Color.ornamentLine.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 40, height: 0.5)

            // Page number in ornamental frame
            ZStack {
                RotatedStar()
                    .fill(DS.Color.accentSoft)
                    .frame(width: 28, height: 28)
                RotatedStar()
                    .stroke(DS.Color.ornamentLine, lineWidth: 0.5)
                    .frame(width: 28, height: 28)
                Text(pageNumber.arabicNumeral)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(DS.Color.accent)
            }

            // Right decorative line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [DS.Color.ornamentLine.opacity(0.5), DS.Color.ornamentLine.opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 40, height: 0.5)
        }
    }

    // MARK: - Page Content Model

    private enum PageItem: Identifiable {
        case surahHeader(SurahDTO)
        case bismillah
        case verse(VerseDTO, isLast: Bool)

        var id: String {
            switch self {
            case .surahHeader(let s): return "header-\(s.id)"
            case .bismillah: return "bismillah-\(UUID().uuidString)"
            case .verse(let v, _): return "\(v.surahId):\(v.verseNumber)"
            }
        }
    }

    private var pageContent: [PageItem] {
        var items: [PageItem] = []
        var lastSurahId: Int?

        for (index, verse) in verses.enumerated() {
            if verse.verseNumber == 1 && verse.surahId != lastSurahId {
                if let surah = surahs[verse.surahId] {
                    items.append(.surahHeader(surah))
                    if surah.id != 1 && surah.id != 9 {
                        items.append(.bismillah)
                    }
                }
            }
            let isLast = index == verses.count - 1 ||
                (index + 1 < verses.count && verses[index + 1].verseNumber == 1 && verses[index + 1].surahId != verse.surahId)
            items.append(.verse(verse, isLast: isLast))
            lastSurahId = verse.surahId
        }

        return items
    }

    // MARK: - Bismillah

    private var bismillahView: some View {
        VStack(spacing: DS.Space.xs) {
            // Top ornamental band
            HStack(spacing: 0) {
                cornerOrnament
                Spacer()
                cornerOrnament
                    .scaleEffect(x: -1, y: 1)
            }
            .frame(height: 6)

            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(DS.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Space.sm)

            // Bottom ornamental band
            HStack(spacing: 0) {
                cornerOrnament
                    .scaleEffect(x: 1, y: -1)
                Spacer()
                cornerOrnament
                    .scaleEffect(x: -1, y: -1)
            }
            .frame(height: 6)
        }
        .padding(.horizontal, DS.Space.md)
        .padding(.vertical, DS.Space.xs)
    }

    private var cornerOrnament: some View {
        HStack(spacing: 2) {
            Rectangle()
                .fill(DS.Color.ornamentLine)
                .frame(width: 30, height: 0.5)
            Circle()
                .fill(DS.Color.accent.opacity(0.5))
                .frame(width: 3, height: 3)
        }
    }

    // MARK: - Verse Row

    private func verseRow(_ verse: VerseDTO, isLast: Bool) -> some View {
        Button {
            selectedVerse = verse
        } label: {
            VStack(spacing: 0) {
                // Verse content
                VStack(alignment: .trailing, spacing: DS.Space.sm) {
                    // Arabic text with inline verse number
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Spacer(minLength: 0)

                        Text(verse.textArabic)
                            .font(showTransliteration ? DS.Typography.arabicLarge : DS.Typography.arabicHero)
                            .foregroundStyle(DS.Color.textPrimary)
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(showTransliteration ? 16 : 22)
                            .fixedSize(horizontal: false, vertical: true)

                        // Verse number ornament
                        VerseNumberOrnament(number: verse.verseNumber)
                            .padding(.leading, DS.Space.xs)
                    }

                    // Transliteration (when enabled)
                    if showTransliteration && !verse.textTransliteration.isEmpty {
                        Text(verse.textTransliteration)
                            .font(DS.Typography.transliterationSm)
                            .italic()
                            .foregroundStyle(DS.Color.accent.opacity(0.55))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, DS.Space.xs)
                    }
                }
                .padding(.vertical, DS.Space.md)
                .padding(.horizontal, DS.Space.xs)

                // Verse separator — ornamental dots
                if !isLast {
                    verseSeparator
                }
            }
        }
        .buttonStyle(VerseButtonStyle())
    }

    // MARK: - Verse Separator

    private var verseSeparator: some View {
        HStack(spacing: DS.Space.sm) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, DS.Color.ornamentLine.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)

            Circle()
                .fill(DS.Color.accent.opacity(0.25))
                .frame(width: 3, height: 3)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [DS.Color.ornamentLine.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
        .padding(.horizontal, DS.Space.x3)
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
                RoundedRectangle(cornerRadius: 12)
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
            // Multi-layered ornament
            RotatedStar()
                .fill(DS.Color.accentSoft)
                .frame(width: 34, height: 34)

            RotatedStar()
                .stroke(DS.Color.accent.opacity(0.4), lineWidth: 0.5)
                .frame(width: 34, height: 34)

            // Inner ring
            Circle()
                .stroke(DS.Color.accent.opacity(0.15), lineWidth: 0.5)
                .frame(width: 20, height: 20)

            Text(number.arabicNumeral)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(DS.Color.accent)
        }
        .frame(width: 36, height: 36)
    }
}

// MARK: - Surah Ornament Header

private struct SurahOrnamentHeader: View {
    let surah: SurahDTO

    var body: some View {
        VStack(spacing: 0) {
            // Decorative top border
            headerBorder

            // Header card with gradient
            VStack(spacing: DS.Space.sm) {
                // Surah number in ornament
                ZStack {
                    RotatedStar()
                        .fill(DS.Color.accent.opacity(0.08))
                        .frame(width: 38, height: 38)
                    RotatedStar()
                        .stroke(DS.Color.accent.opacity(0.3), lineWidth: 0.5)
                        .frame(width: 38, height: 38)
                    Text("\(surah.id)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(DS.Color.accent)
                }

                // Arabic name — large, elegant
                Text(surah.nameArabic)
                    .font(.system(size: 30, weight: .regular))
                    .foregroundStyle(DS.Color.textPrimary)

                // Turkish name
                Text(surah.nameTurkish)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DS.Color.accent.opacity(0.8))
                    .tracking(1)

                // Info line
                HStack(spacing: DS.Space.sm) {
                    infoChip(surah.revelationType == "Meccan" ? "Mekki" : "Medeni")
                    infoDot
                    infoChip("\(surah.verseCount) ayet")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.xl)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DS.Color.surahHeader,
                                    DS.Color.surahHeader.opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Subtle inner glow
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    DS.Color.accent.opacity(0.15),
                                    DS.Color.ornamentLine.opacity(0.1),
                                    DS.Color.accent.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )

            // Decorative bottom border
            headerBorder
                .scaleEffect(x: 1, y: -1)
        }
    }

    private var headerBorder: some View {
        HStack(spacing: DS.Space.xs) {
            // Left corner piece
            HStack(spacing: 2) {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 4))
                    .foregroundStyle(DS.Color.accent.opacity(0.4))
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [DS.Color.ornamentLine, DS.Color.ornamentLine.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)
            }

            // Center ornament cluster
            HStack(spacing: 3) {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 4))
                    .foregroundStyle(DS.Color.accent.opacity(0.35))
                Image(systemName: "diamond.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(DS.Color.accent.opacity(0.6))
                Image(systemName: "star.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(DS.Color.accent.opacity(0.7))
                Image(systemName: "diamond.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(DS.Color.accent.opacity(0.6))
                Image(systemName: "diamond.fill")
                    .font(.system(size: 4))
                    .foregroundStyle(DS.Color.accent.opacity(0.35))
            }

            // Right corner piece
            HStack(spacing: 2) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [DS.Color.ornamentLine.opacity(0), DS.Color.ornamentLine],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)
                Image(systemName: "diamond.fill")
                    .font(.system(size: 4))
                    .foregroundStyle(DS.Color.accent.opacity(0.4))
            }
        }
        .frame(height: 10)
        .padding(.horizontal, DS.Space.sm)
    }

    private func infoChip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(DS.Color.textSecondary)
            .tracking(0.5)
    }

    private var infoDot: some View {
        Circle()
            .fill(DS.Color.accent.opacity(0.3))
            .frame(width: 3, height: 3)
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

// MARK: - Rotated Star Shape

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
