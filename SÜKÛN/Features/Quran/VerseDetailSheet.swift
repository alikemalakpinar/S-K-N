import SwiftUI

struct VerseDetailSheet: View {
    let verse: VerseDTO
    let surahName: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.xl) {
                    // Verse reference
                    HStack {
                        Text("\(surahName) \(verse.surahId):\(verse.verseNumber)")
                            .font(DS.Typography.sectionHead)
                            .foregroundStyle(DS.Color.accent)
                        Spacer()
                        Text("Sayfa \(verse.pageNumber)")
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    // Arabic text
                    Text(verse.textArabic)
                        .font(.system(size: 28, weight: .regular))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(DS.Color.textPrimary)
                        .lineSpacing(12)

                    Hairline()

                    // Transliteration
                    if !verse.textTransliteration.isEmpty {
                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                            Text("Okunuş")
                                .font(DS.Typography.sectionHead)
                                .foregroundStyle(DS.Color.accent)
                            Text(verse.textTransliteration)
                                .font(.system(size: 16, weight: .regular, design: .serif))
                                .foregroundStyle(DS.Color.textSecondary)
                                .italic()
                        }
                    }

                    // Translation (Meal)
                    if !verse.textTranslation.isEmpty {
                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                            Text("Meal")
                                .font(DS.Typography.sectionHead)
                                .foregroundStyle(DS.Color.accent)
                            Text(verse.textTranslation)
                                .font(DS.Typography.body)
                                .foregroundStyle(DS.Color.textPrimary)
                                .lineSpacing(4)
                        }
                    }

                    // Tefsir
                    if !verse.textTefsir.isEmpty {
                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                            Text("Tefsir")
                                .font(DS.Typography.sectionHead)
                                .foregroundStyle(DS.Color.accent)
                            Text(verse.textTefsir)
                                .font(DS.Typography.caption)
                                .foregroundStyle(DS.Color.textSecondary)
                                .lineSpacing(4)
                        }
                    }

                    Spacer(minLength: DS.Space.x4)
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.lg)
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("\(verse.surahId):\(verse.verseNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
