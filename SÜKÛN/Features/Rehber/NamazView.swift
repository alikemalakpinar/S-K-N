import SwiftUI

struct NamazView: View {
    let viewModel: RehberViewModel

    enum DisplayMode: String, CaseIterable {
        case metin = "Metin"
        case okunus = "Okunuş"
        case anlam = "Anlam"
    }

    @State private var displayModes: Set<DisplayMode> = [.metin, .okunus]

    var body: some View {
        Group {
            if let namaz = viewModel.namaz {
                ScrollView {
                    VStack(spacing: DS.Space.lg) {
                        displayToggle

                        ForEach(namaz.postures) { posture in
                            postureCard(posture)
                        }
                    }
                    .padding(DS.Space.lg)
                }
            } else {
                SKNErrorState(
                    icon: "doc.text",
                    message: "Namaz verileri yüklenemedi."
                )
            }
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle("Namazın Anatomisi")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Display Toggle

    private var displayToggle: some View {
        HStack(spacing: DS.Space.sm) {
            ForEach(DisplayMode.allCases, id: \.self) { mode in
                let isOn = displayModes.contains(mode)
                Button {
                    withAnimation(DS.Motion.standard) {
                        if isOn {
                            displayModes.remove(mode)
                        } else {
                            displayModes.insert(mode)
                        }
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(DS.Typography.caption)
                        .padding(.horizontal, DS.Space.md)
                        .padding(.vertical, DS.Space.sm)
                        .foregroundStyle(isOn ? DS.Color.backgroundPrimary : DS.Color.textSecondary)
                        .background(
                            isOn ? DS.Color.accent : DS.Color.backgroundSecondary,
                            in: Capsule()
                        )
                }
            }
            Spacer()
        }
    }

    // MARK: - Posture Card

    private func postureCard(_ posture: NamazPosture) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                Text(posture.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(DS.Color.accent)

                Text(posture.actionText)
                    .font(DS.Typography.body)
                    .foregroundStyle(DS.Color.textSecondary)

                // Inline recitation
                if let recitation = posture.recitation {
                    recitationBlock(recitation)
                }

                // Library reference
                if let reading = viewModel.libraryReading(for: posture.libraryRefId) {
                    Hairline()
                    libraryRefBlock(reading)
                }
            }
        }
    }

    private func recitationBlock(_ r: Recitation) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Hairline()

            if displayModes.contains(.metin) {
                Text(r.arabic)
                    .font(DS.Typography.arabicVerse)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(DS.Typography.LineSpacing.arabic)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(DS.Color.textPrimary)
            }

            if displayModes.contains(.okunus) {
                Text(r.transliteration)
                    .font(DS.Typography.transliteration)
                    .foregroundStyle(DS.Color.accent.opacity(0.7))
            }

            if displayModes.contains(.anlam) {
                Text(r.meaning)
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
                    .italic()
            }
        }
    }

    private func libraryRefBlock(_ reading: LibraryReading) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(reading.title)
                .font(DS.Typography.captionSm)
                .foregroundStyle(DS.Color.accent)
                .tracking(0.5)

            if displayModes.contains(.metin) {
                Text(reading.arabic)
                    .font(DS.Typography.arabicVerse)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(DS.Typography.LineSpacing.arabic)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(DS.Color.textPrimary)
            }

            if displayModes.contains(.okunus) {
                Text(reading.transliteration)
                    .font(DS.Typography.transliteration)
                    .foregroundStyle(DS.Color.accent.opacity(0.7))
            }

            if displayModes.contains(.anlam) {
                Text(reading.meaning)
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textSecondary)
                    .italic()
            }
        }
    }
}
