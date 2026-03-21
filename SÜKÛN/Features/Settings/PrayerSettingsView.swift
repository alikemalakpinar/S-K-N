import SwiftUI
import SwiftData

struct PrayerSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var settings: UserSetting
    let viewModel: SettingsViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Calculation Method
                calculationSection

                // Manual Offsets
                offsetSection
            }
            .padding(.bottom, DS.Space.x4)
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle(L10n.Settings.prayerSettings)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Calculation

    private var calculationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSSectionHeader(L10n.Settings.calculationMethod, serif: true)

            DSCard {
                VStack(spacing: DS.Space.lg) {
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Text(L10n.Settings.method)
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)

                        Picker(L10n.Settings.method, selection: Binding(
                            get: { settings.calculationMethod },
                            set: { settings.calculationMethod = $0; viewModel.saveAndReschedule(context: modelContext) }
                        )) {
                            ForEach(viewModel.calculationMethods, id: \.self) { method in
                                Text(method).tag(method)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(DS.Color.accent)
                    }

                    Hairline()

                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        Text(L10n.Settings.asrSchool)
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)

                        DSSegmentedControl(
                            ["standard", "hanafi"],
                            selected: Binding(
                                get: { settings.asrMethod },
                                set: { settings.asrMethod = $0; viewModel.saveAndReschedule(context: modelContext) }
                            ),
                            label: { $0 == "standard" ? L10n.Settings.shafii : L10n.Settings.hanafi }
                        )
                    }
                }
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    // MARK: - Offsets

    private var offsetSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSSectionHeader(L10n.Settings.manualOffsets, serif: true)

            DSCard {
                VStack(spacing: DS.Space.md) {
                    DSStepperRow(L10n.Prayer.fajr, value: $settings.fajrOffset, unit: L10n.Common.minuteAbbrev, icon: "sun.horizon") {
                        viewModel.saveAndReschedule(context: modelContext)
                    }
                    Hairline()
                    DSStepperRow(L10n.Prayer.dhuhr, value: $settings.dhuhrOffset, unit: L10n.Common.minuteAbbrev, icon: "sun.max") {
                        viewModel.saveAndReschedule(context: modelContext)
                    }
                    Hairline()
                    DSStepperRow(L10n.Prayer.asr, value: $settings.asrOffset, unit: L10n.Common.minuteAbbrev, icon: "sun.min") {
                        viewModel.saveAndReschedule(context: modelContext)
                    }
                    Hairline()
                    DSStepperRow(L10n.Prayer.maghrib, value: $settings.maghribOffset, unit: L10n.Common.minuteAbbrev, icon: "sunset") {
                        viewModel.saveAndReschedule(context: modelContext)
                    }
                    Hairline()
                    DSStepperRow(L10n.Prayer.isha, value: $settings.ishaOffset, unit: L10n.Common.minuteAbbrev, icon: "moon.stars") {
                        viewModel.saveAndReschedule(context: modelContext)
                    }
                }
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }
}
