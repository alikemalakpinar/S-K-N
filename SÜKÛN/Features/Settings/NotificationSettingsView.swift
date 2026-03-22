import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var settings: UserSetting
    let viewModel: SettingsViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                DSSectionHeader(L10n.Settings.notifications, serif: true)

                DSCard {
                    VStack(spacing: DS.Space.md) {
                        DSToggleRow(L10n.Prayer.fajr, icon: "sun.horizon", isOn: $settings.fajrNotification) {
                            viewModel.saveAndReschedule(context: modelContext)
                        }
                        Hairline()
                        DSToggleRow(L10n.Prayer.dhuhr, icon: "sun.max", isOn: $settings.dhuhrNotification) {
                            viewModel.saveAndReschedule(context: modelContext)
                        }
                        Hairline()
                        DSToggleRow(L10n.Prayer.asr, icon: "sun.min", isOn: $settings.asrNotification) {
                            viewModel.saveAndReschedule(context: modelContext)
                        }
                        Hairline()
                        DSToggleRow(L10n.Prayer.maghrib, icon: "sunset", isOn: $settings.maghribNotification) {
                            viewModel.saveAndReschedule(context: modelContext)
                        }
                        Hairline()
                        DSToggleRow(L10n.Prayer.isha, icon: "moon.stars", isOn: $settings.ishaNotification) {
                            viewModel.saveAndReschedule(context: modelContext)
                        }
                        Hairline()
                        DSStepperRow(L10n.Settings.alertBefore, value: $settings.notificationMinutesBefore, range: 0...30, unit: L10n.Common.minuteAbbrev, icon: "clock") {
                            viewModel.saveAndReschedule(context: modelContext)
                        }
                        Hairline()
                        DSToggleRow(L10n.Settings.liveActivity, icon: "rectangle.badge.person.crop", isOn: $settings.liveActivityEnabled) {
                            viewModel.saveSettings(context: modelContext)
                        }
                    }
                }
                .padding(.horizontal, DS.Space.lg)

                DSButton(L10n.Settings.requestNotification, icon: "bell.badge", style: .secondary, size: .medium) {
                    Task { await viewModel.requestNotifications() }
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.md)
            }
            .padding(.bottom, DS.Space.x4)
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle(L10n.Settings.notifications)
        .navigationBarTitleDisplayMode(.inline)
    }
}
