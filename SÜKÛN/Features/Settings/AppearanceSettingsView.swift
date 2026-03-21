import SwiftUI
import SwiftData

struct AppearanceSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var settings: UserSetting
    let viewModel: SettingsViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Visual Theme Picker
                DSSectionHeader(L10n.Settings.themeLabel, serif: true)

                themeCards

                // Font Scale
                DSSectionHeader(L10n.Settings.fontSizeLabel, serif: true)

                DSCard {
                    HStack(spacing: DS.Space.md) {
                        Image(systemName: "textformat.size")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(DS.Color.accent)
                            .frame(width: 30, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                                    .fill(DS.Color.accent.opacity(0.12))
                            )

                        Text(L10n.Settings.fontSizeLabel)
                            .font(DS.Typography.listTitle)
                            .foregroundStyle(DS.Color.textPrimary)

                        Slider(value: $settings.fontScale, in: 0.8...1.5, step: 0.1)
                            .tint(DS.Color.accent)
                            .onChange(of: settings.fontScale) {
                                viewModel.saveSettings(context: modelContext)
                            }

                        Text(String(format: "%.1fx", settings.fontScale))
                            .font(DS.Typography.bodyMedium)
                            .foregroundStyle(DS.Color.accent)
                            .monospacedDigit()
                            .frame(width: 36, alignment: .trailing)
                    }
                }
                .padding(.horizontal, DS.Space.lg)
            }
            .padding(.bottom, DS.Space.x4)
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle(L10n.Settings.appearance)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Visual Theme Cards

    private var themeCards: some View {
        HStack(spacing: DS.Space.md) {
            themeOption(
                key: "system",
                label: L10n.Settings.themeSystem,
                icon: "circle.lefthalf.filled"
            )
            themeOption(
                key: "light",
                label: L10n.Settings.themeLight,
                icon: "sun.max.fill"
            )
            themeOption(
                key: "dark",
                label: L10n.Settings.themeDark,
                icon: "moon.fill"
            )
        }
        .padding(.horizontal, DS.Space.lg)
    }

    private func themeOption(key: String, label: String, icon: String) -> some View {
        let isSelected = settings.theme == key

        return Button {
            DS.Haptic.softTap()
            withAnimation(DS.Motion.tap) {
                settings.theme = key
                viewModel.saveSettings(context: modelContext)
            }
        } label: {
            VStack(spacing: DS.Space.md) {
                // Mini phone mockup
                RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                    .fill(mockupBackground(for: key))
                    .frame(height: 80)
                    .overlay {
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(mockupContentColor(for: key))
                                .frame(width: 40, height: 6)
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(mockupContentColor(for: key).opacity(0.5))
                                .frame(width: 30, height: 6)
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(mockupContentColor(for: key).opacity(0.3))
                                .frame(width: 36, height: 6)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                            .stroke(
                                isSelected ? DS.Color.accent : DS.Color.hairline,
                                lineWidth: isSelected ? 2 : 0.5
                            )
                    )

                // Icon
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? DS.Color.accent : DS.Color.textSecondary)

                // Label
                Text(label)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? DS.Color.textPrimary : DS.Color.textSecondary)
            }
            .padding(.vertical, DS.Space.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(isSelected ? DS.Color.accentSoft : DS.Color.cardElevated)
            )
        }
        .buttonStyle(.plain)
    }

    private func mockupBackground(for key: String) -> Color {
        switch key {
        case "light": Color(.systemGray6)
        case "dark": Color(.systemGray)
        default:
            // System: half-and-half
            Color(.systemGray5)
        }
    }

    private func mockupContentColor(for key: String) -> Color {
        switch key {
        case "light": .black.opacity(0.15)
        case "dark": .white.opacity(0.25)
        default: .gray.opacity(0.4)
        }
    }
}
