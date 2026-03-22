import SwiftUI

struct VerseDetailSheet: View {
    let verse: VerseDTO
    let surahName: String

    @Environment(\.dismiss) private var dismiss
    @State private var showTefsir = false

    var body: some View {
        VStack(spacing: 0) {
            DSSheetHeader(
                "\(surahName) \u{2022} \(verse.surahId):\(verse.verseNumber)",
                onDismiss: { dismiss() }
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Space.lg) {
                    // Reference badge
                    referenceBadge
                        .padding(.top, DS.Space.sm)

                    // Arabic card
                    arabicCard

                    // Transliteration card
                    if !verse.textTransliteration.isEmpty {
                        transliterationCard
                    }

                    // Translation card
                    if !verse.textTranslation.isEmpty {
                        translationCard
                    }

                    // Tefsir card (expandable)
                    if !verse.textTefsir.isEmpty {
                        tefsirCard
                    }

                    Spacer(minLength: DS.Space.x3)
                }
                .padding(.horizontal, DS.Space.lg)
            }
        }
        .background(DS.Color.backgroundPrimary)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(24)
    }

    // MARK: - Reference Badge

    private var referenceBadge: some View {
        HStack(spacing: DS.Space.md) {
            Label {
                Text("Sayfa \(verse.pageNumber)")
                    .font(DS.Typography.captionSm)
            } icon: {
                Image(systemName: "book.pages")
                    .font(DS.Typography.alongSans(size: 10, weight: "Regular"))
            }
            .foregroundStyle(DS.Color.textSecondary)

            Spacer()

            // Verse number ornament
            HStack(spacing: 4) {
                Text("Ayet")
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textSecondary)
                Text("\(verse.verseNumber)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(DS.Color.accent)
            }
        }
    }

    // MARK: - Arabic Card

    private var arabicCard: some View {
        VStack(spacing: DS.Space.md) {
            Text(verse.textArabic)
                .font(DS.Typography.arabicHero)
                .multilineTextAlignment(.center)
                .lineSpacing(16)
                .foregroundStyle(DS.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Space.xl)
                .padding(.horizontal, DS.Space.lg)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DS.Color.quranCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DS.Color.ornamentLine, lineWidth: 0.5)
        )
    }

    // MARK: - Transliteration Card

    private var transliterationCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            sectionLabel("Okunuş", icon: "text.word.spacing")
            Text(verse.textTransliteration)
                .font(DS.Typography.transliteration)
                .foregroundStyle(DS.Color.accent.opacity(0.7))
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DS.Color.backgroundSecondary)
        )
    }

    // MARK: - Translation Card

    private var translationCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            sectionLabel("Meal", icon: "text.book.closed")
            Text(verse.textTranslation)
                .font(DS.Typography.body)
                .foregroundStyle(DS.Color.textPrimary)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DS.Color.backgroundSecondary)
        )
    }

    // MARK: - Tefsir Card

    private var tefsirCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Button {
                withAnimation(DS.Motion.standard) {
                    showTefsir.toggle()
                }
            } label: {
                HStack {
                    sectionLabel("Tefsir", icon: "book.pages.fill")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(DS.Typography.alongSans(size: 12, weight: "Medium"))
                        .foregroundStyle(DS.Color.accent)
                        .rotationEffect(.degrees(showTefsir ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            if showTefsir {
                Text(verse.textTefsir)
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DS.Color.backgroundSecondary)
        )
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String, icon: String) -> some View {
        Label {
            Text(text)
                .font(DS.Typography.sectionHead)
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 11))
        }
        .foregroundStyle(DS.Color.accent)
    }
}
