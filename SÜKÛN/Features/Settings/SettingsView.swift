import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SettingsViewModel
    @State private var appeared = false
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        _viewModel = State(initialValue: SettingsViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if let settings = viewModel.settings {
                    VStack(spacing: 0) {
                        // App hero card
                        appCard
                            .dsAppear(loaded: appeared, index: 0)

                        // Navigation hub
                        hubSection(settings)
                            .dsAppear(loaded: appeared, index: 1)

                        // Quick toggles (most-used)
                        quickTogglesSection(settings)
                            .dsAppear(loaded: appeared, index: 2)

                        // Visual theme picker (inline)
                        inlineThemePicker(settings)
                            .dsAppear(loaded: appeared, index: 3)
                    }
                    .padding(.bottom, DS.Space.x4)
                    .onAppear {
                        withAnimation(DS.Motion.slowReveal) { appeared = true }
                    }
                } else {
                    DSSkeletonGroup(rows: 6)
                        .padding(.top, DS.Space.x3)
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle(L10n.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .tint(DS.Color.accent)
            .task {
                viewModel.loadSettings(context: modelContext)
            }
        }
    }

    // MARK: - App Hero Card

    private var appCard: some View {
        VStack(spacing: DS.Space.lg) {
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(DS.Color.accent.opacity(0.8))
                    .overlay(
                        FluidBackgroundView()
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: DS.Color.accent.opacity(0.3), radius: 12, y: 4)

                Image(systemName: "heart.fill")
                    .font(DS.Typography.alongSans(size: 28, weight: "Medium"))
                    .foregroundStyle(.white)
            }

            VStack(spacing: DS.Space.xs) {
                Text("Sükûn")
                    .font(DS.Typography.displayBody)
                    .foregroundStyle(DS.Color.textPrimary)

                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                Text("\(L10n.Settings.version) \(version)")
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textTertiary)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.x3)
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Navigation Hub

    private func hubSection(_ settings: UserSetting) -> some View {
        DSCard {
            VStack(spacing: 0) {
                NavigationLink {
                    PrayerSettingsView(settings: settings, viewModel: viewModel)
                } label: {
                    settingsRow(
                        icon: "moon.stars",
                        iconColor: DS.Color.accent,
                        title: L10n.Settings.prayerSettings,
                        subtitle: L10n.Settings.prayerSettingsSubtitle
                    )
                }
                .buttonStyle(.plain)

                Hairline()

                NavigationLink {
                    NotificationSettingsView(settings: settings, viewModel: viewModel)
                } label: {
                    settingsRow(
                        icon: "bell.badge",
                        iconColor: .red,
                        title: L10n.Settings.notifications,
                        subtitle: L10n.Settings.notificationsSubtitle
                    )
                }
                .buttonStyle(.plain)

                Hairline()

                NavigationLink {
                    AppearanceSettingsView(settings: settings, viewModel: viewModel)
                } label: {
                    settingsRow(
                        icon: "paintbrush",
                        iconColor: .purple,
                        title: L10n.Settings.appearance,
                        subtitle: L10n.Settings.appearanceSubtitle
                    )
                }
                .buttonStyle(.plain)

                Hairline()

                NavigationLink {
                    AboutView()
                } label: {
                    settingsRow(
                        icon: "info.circle",
                        iconColor: .blue,
                        title: L10n.Settings.about,
                        subtitle: nil
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DS.Space.lg)
    }

    private func settingsRow(icon: String, iconColor: Color, title: String, subtitle: String?) -> some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: icon)
                .font(DS.Typography.bodyMedium)
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.sm + 2, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DS.Typography.listTitle)
                    .foregroundStyle(DS.Color.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textTertiary)
        }
        .padding(.vertical, DS.Space.sm + 2)
        .contentShape(Rectangle())
    }

    // MARK: - Quick Toggles (most-used settings surfaced)

    private func quickTogglesSection(_ settings: UserSetting) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            DSSectionHeader(L10n.Settings.notifications, serif: true)

            DSCard {
                VStack(spacing: DS.Space.md) {
                    DSToggleRow(L10n.Prayer.fajr, icon: "sun.horizon", isOn: Binding(
                        get: { settings.fajrNotification },
                        set: { settings.fajrNotification = $0 }
                    )) { viewModel.saveAndReschedule(context: modelContext) }

                    Hairline()

                    DSToggleRow(L10n.Prayer.maghrib, icon: "sunset", isOn: Binding(
                        get: { settings.maghribNotification },
                        set: { settings.maghribNotification = $0 }
                    )) { viewModel.saveAndReschedule(context: modelContext) }

                    Hairline()

                    DSToggleRow(L10n.Settings.liveActivity, icon: "rectangle.badge.person.crop", isOn: Binding(
                        get: { settings.liveActivityEnabled },
                        set: { settings.liveActivityEnabled = $0 }
                    )) { viewModel.saveSettings(context: modelContext) }
                }
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    // MARK: - Inline Theme Picker

    private func inlineThemePicker(_ settings: UserSetting) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            DSSectionHeader(L10n.Settings.themeLabel, serif: true)

            HStack(spacing: DS.Space.md) {
                themeChip(key: "system", label: L10n.Settings.themeSystem, icon: "circle.lefthalf.filled", settings: settings)
                themeChip(key: "light", label: L10n.Settings.themeLight, icon: "sun.max.fill", settings: settings)
                themeChip(key: "dark", label: L10n.Settings.themeDark, icon: "moon.fill", settings: settings)
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    private func themeChip(key: String, label: String, icon: String, settings: UserSetting) -> some View {
        let isSelected = settings.theme == key

        return Button {
            DS.Haptic.softTap()
            withAnimation(DS.Motion.tap) {
                settings.theme = key
                viewModel.saveSettings(context: modelContext)
            }
        } label: {
            VStack(spacing: DS.Space.sm) {
                Image(systemName: icon)
                    .font(DS.Typography.alongSans(size: 20, weight: "Medium"))
                    .foregroundStyle(isSelected ? DS.Color.accent : DS.Color.textSecondary)

                Text(label)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? DS.Color.textPrimary : DS.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.lg)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(isSelected ? DS.Color.accentSoft : .clear)
            )
            .dsGlass(isSelected ? .regular : .thin, cornerRadius: DS.Radius.lg)
            .shadow(color: .black.opacity(isSelected ? 0.08 : 0.02), radius: 8, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(isSelected ? DS.Color.accent.opacity(0.4) : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Settings") {
    DSPreview { c in SettingsView(container: c) }
}
