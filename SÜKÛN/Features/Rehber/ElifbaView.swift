import SwiftUI

struct ElifbaView: View {
    let viewModel: RehberViewModel
    @State private var selectedLetter: ElifbaLetter?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: DS.Space.md), count: 3)

    var body: some View {
        Group {
            if let elifba = viewModel.elifba {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: DS.Space.md) {
                        ForEach(elifba.items) { letter in
                            letterTile(letter)
                        }
                    }
                    .padding(DS.Space.lg)
                }
            } else {
                SKNErrorState(
                    icon: "doc.text",
                    message: "Elifba verileri yüklenemedi."
                )
            }
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle("Harfler ve Sesler")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedLetter) { letter in
            LetterDetailSheet(letter: letter)
                .presentationDetents([.medium])
        }
    }

    private func letterTile(_ letter: ElifbaLetter) -> some View {
        Button {
            selectedLetter = letter
        } label: {
            VStack(spacing: DS.Space.sm) {
                Text(letter.symbol)
                    .font(DS.Typography.arabicHero)
                    .foregroundStyle(DS.Color.accent)

                Text(letter.name)
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.xl)
            .background(DS.Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(LetterTileButtonStyle())
    }
}

// MARK: - Letter Detail Sheet

struct LetterDetailSheet: View {
    let letter: ElifbaLetter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            DSSheetHeader(letter.name, onDismiss: { dismiss() })

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Space.xl) {
                    Text(letter.symbol)
                        .font(DS.Typography.arabicDisplay)
                        .foregroundStyle(DS.Color.accent)
                        .padding(.top, DS.Space.lg)

                    // Forms
                    HStack(spacing: DS.Space.x2) {
                        formColumn("Başta", letter.forms.initial)
                        formColumn("Ortada", letter.forms.medial)
                        formColumn("Sonda", letter.forms.final)
                    }
                    .padding(.horizontal, DS.Space.lg)

                    Hairline()
                        .padding(.horizontal, DS.Space.lg)

                    Text(letter.description)
                        .font(DS.Typography.body)
                        .foregroundStyle(DS.Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DS.Space.lg)

                    Spacer(minLength: DS.Space.x2)
                }
            }
        }
        .background(DS.Color.backgroundPrimary)
    }

    private func formColumn(_ label: String, _ form: String) -> some View {
        VStack(spacing: DS.Space.xs) {
            Text(label)
                .font(DS.Typography.captionSm)
                .foregroundStyle(DS.Color.textSecondary)
            Text(form)
                .font(DS.Typography.arabicLarge)
                .foregroundStyle(DS.Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Button Style

private struct LetterTileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(DS.Motion.tap, value: configuration.isPressed)
    }
}
