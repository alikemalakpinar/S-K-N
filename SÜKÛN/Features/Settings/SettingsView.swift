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
                        NavigationLink("Hakkında") {
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
            .navigationTitle("Ayarlar")
            .tint(DS.Color.accent)
            .task {
                viewModel.loadSettings(context: modelContext)
            }
        }
    }

    // MARK: - Sections

    private func calculationSection(_ settings: UserSetting) -> some View {
        Section {
            Picker("Yöntem", selection: Binding(
                get: { settings.calculationMethod },
                set: { settings.calculationMethod = $0; viewModel.saveSettings(context: modelContext) }
            )) {
                ForEach(viewModel.calculationMethods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .foregroundStyle(DS.Color.textPrimary)

            Picker("İkindi Mezhebi", selection: Binding(
                get: { settings.asrMethod },
                set: { settings.asrMethod = $0; viewModel.saveSettings(context: modelContext) }
            )) {
                Text("Standart (Şâfiî)").tag("standard")
                Text("Hanefî").tag("hanafi")
            }
            .foregroundStyle(DS.Color.textPrimary)
        } header: {
            Text("Hesaplama Yöntemi")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .listRowBackground(DS.Color.backgroundSecondary)
    }

    private func offsetSection(_ settings: UserSetting) -> some View {
        Section {
            Stepper("Sabah: \(settings.fajrOffset)", value: Binding(
                get: { settings.fajrOffset },
                set: { settings.fajrOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
            Stepper("Öğle: \(settings.dhuhrOffset)", value: Binding(
                get: { settings.dhuhrOffset },
                set: { settings.dhuhrOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
            Stepper("İkindi: \(settings.asrOffset)", value: Binding(
                get: { settings.asrOffset },
                set: { settings.asrOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
            Stepper("Akşam: \(settings.maghribOffset)", value: Binding(
                get: { settings.maghribOffset },
                set: { settings.maghribOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
            Stepper("Yatsı: \(settings.ishaOffset)", value: Binding(
                get: { settings.ishaOffset },
                set: { settings.ishaOffset = $0; viewModel.saveSettings(context: modelContext) }
            ), in: -30...30)
        } header: {
            Text("Manuel Düzeltmeler (dakika)")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .listRowBackground(DS.Color.backgroundSecondary)
        .foregroundStyle(DS.Color.textPrimary)
    }

    private func notificationSection(_ settings: UserSetting) -> some View {
        Section {
            Toggle("Sabah", isOn: Binding(
                get: { settings.fajrNotification },
                set: { settings.fajrNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))
            Toggle("Öğle", isOn: Binding(
                get: { settings.dhuhrNotification },
                set: { settings.dhuhrNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))
            Toggle("İkindi", isOn: Binding(
                get: { settings.asrNotification },
                set: { settings.asrNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))
            Toggle("Akşam", isOn: Binding(
                get: { settings.maghribNotification },
                set: { settings.maghribNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))
            Toggle("Yatsı", isOn: Binding(
                get: { settings.ishaNotification },
                set: { settings.ishaNotification = $0; viewModel.saveSettings(context: modelContext) }
            ))

            Stepper("\(settings.notificationMinutesBefore) dk önce uyar", value: Binding(
                get: { settings.notificationMinutesBefore },
                set: { settings.notificationMinutesBefore = $0; viewModel.saveSettings(context: modelContext) }
            ), in: 0...30)

            Button("Bildirim İzni İste") {
                Task { await viewModel.requestNotifications() }
            }
            .foregroundStyle(DS.Color.accent)
        } header: {
            Text("Bildirimler")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .listRowBackground(DS.Color.backgroundSecondary)
        .foregroundStyle(DS.Color.textPrimary)
    }

    private func appearanceSection(_ settings: UserSetting) -> some View {
        Section {
            Picker("Tema", selection: Binding(
                get: { settings.theme },
                set: { settings.theme = $0; viewModel.saveSettings(context: modelContext) }
            )) {
                Text("Sistem").tag("system")
                Text("Açık").tag("light")
                Text("Koyu").tag("dark")
            }
            .foregroundStyle(DS.Color.textPrimary)

            HStack {
                Text("Yazı Boyutu")
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
            Text("Görünüm")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .listRowBackground(DS.Color.backgroundSecondary)
    }
}
