import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SettingsViewModel

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: SettingsViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            Form {
                if let settings = viewModel.settings {
                    calculationSection(settings)
                    offsetSection(settings)
                    notificationSection(settings)
                    appearanceSection(settings)

                    Section {
                        NavigationLink("About") {
                            AboutView()
                        }
                        .foregroundStyle(DS.Color.textPrimary)
                    }
                } else {
                    ProgressView()
                        .tint(DS.Color.accent)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Settings")
            .tint(DS.Color.accent)
            .task {
                viewModel.loadSettings(context: modelContext)
            }
        }
    }

    // MARK: - Sections

    private func calculationSection(_ settings: UserSetting) -> some View {
        Section {
            Picker("Method", selection: Binding(
                get: { settings.calculationMethod },
                set: { settings.calculationMethod = $0; viewModel.saveSettings(context: modelContext) }
            )) {
                ForEach(viewModel.calculationMethods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .foregroundStyle(DS.Color.textPrimary)

            Picker("Asr Juristic", selection: Binding(
                get: { settings.asrMethod },
                set: { settings.asrMethod = $0; viewModel.saveSettings(context: modelContext) }
            )) {
                Text("Standard (Shafi'i)").tag("standard")
                Text("Hanafi").tag("hanafi")
            }
            .foregroundStyle(DS.Color.textPrimary)
        } header: {
            Text("Calculation Method")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .listRowBackground(DS.Color.backgroundSecondary)
    }

    private func offsetSection(_ settings: UserSetting) -> some View {
        Section {
            Stepper("Fajr: \(settings.fajrOffset)", value: Binding(
                get: { settings.fajrOffset },
                set: { settings.fajrOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
            Stepper("Dhuhr: \(settings.dhuhrOffset)", value: Binding(
                get: { settings.dhuhrOffset },
                set: { settings.dhuhrOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
            Stepper("Asr: \(settings.asrOffset)", value: Binding(
                get: { settings.asrOffset },
                set: { settings.asrOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
            Stepper("Maghrib: \(settings.maghribOffset)", value: Binding(
                get: { settings.maghribOffset },
                set: { settings.maghribOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
            Stepper("Isha: \(settings.ishaOffset)", value: Binding(
                get: { settings.ishaOffset },
                set: { settings.ishaOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
        } header: {
            Text("Manual Offsets (minutes)")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .listRowBackground(DS.Color.backgroundSecondary)
        .foregroundStyle(DS.Color.textPrimary)
    }

    private func notificationSection(_ settings: UserSetting) -> some View {
        Section {
            Toggle("Fajr", isOn: Binding(
                get: { settings.fajrNotification },
                set: { settings.fajrNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))
            Toggle("Dhuhr", isOn: Binding(
                get: { settings.dhuhrNotification },
                set: { settings.dhuhrNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))
            Toggle("Asr", isOn: Binding(
                get: { settings.asrNotification },
                set: { settings.asrNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))
            Toggle("Maghrib", isOn: Binding(
                get: { settings.maghribNotification },
                set: { settings.maghribNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))
            Toggle("Isha", isOn: Binding(
                get: { settings.ishaNotification },
                set: { settings.ishaNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))

            Stepper("Alert \(settings.notificationMinutesBefore) min before", value: Binding(
                get: { settings.notificationMinutesBefore },
                set: { settings.notificationMinutesBefore = $0; viewModel.saveSettings(context: modelContext) }
            ), in: 0...30)

            Button("Request Notification Permission") {
                Task { await viewModel.requestNotifications() }
            }
            .foregroundStyle(DS.Color.accent)
        } header: {
            Text("Notifications")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .listRowBackground(DS.Color.backgroundSecondary)
        .foregroundStyle(DS.Color.textPrimary)
    }

    private func appearanceSection(_ settings: UserSetting) -> some View {
        Section {
            Picker("Theme", selection: Binding(
                get: { settings.theme },
                set: { settings.theme = $0; viewModel.saveSettings(context: modelContext) }
            )) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .foregroundStyle(DS.Color.textPrimary)

            HStack {
                Text("Font Scale")
                    .foregroundStyle(DS.Color.textPrimary)
                Slider(value: Binding(
                    get: { settings.fontScale },
                    set: { settings.fontScale = $0; viewModel.saveSettings(context: modelContext) }
                ), in: 0.8...1.5, step: 0.1)
                .tint(DS.Color.accent)
                Text(String(format: "%.1f", settings.fontScale))
                    .monospacedDigit()
                    .foregroundStyle(DS.Color.textSecondary)
            }
        } header: {
            Text("Appearance")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .listRowBackground(DS.Color.backgroundSecondary)
    }
}
