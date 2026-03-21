import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DSListRow — Unified list row component for Settings & lists
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MARK: - Standard Navigation Row

struct DSListRow: View {
    let icon: String?
    let iconColor: SwiftUI.Color
    let title: String
    let subtitle: String?
    let trailing: String?
    let action: (() -> Void)?

    init(
        _ title: String,
        icon: String? = nil,
        iconColor: SwiftUI.Color = DS.Color.accent,
        subtitle: String? = nil,
        trailing: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.subtitle = subtitle
        self.trailing = trailing
        self.action = action
    }

    var body: some View {
        Button {
            DS.Haptic.softTap()
            action?()
        } label: {
            HStack(spacing: DS.Space.md) {
                if let icon {
                    iconView(icon, color: iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DS.Typography.listTitle)
                        .foregroundStyle(DS.Color.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                if let trailing {
                    Text(trailing)
                        .font(DS.Typography.footnote)
                        .foregroundStyle(DS.Color.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.Color.textTertiary)
            }
            .padding(.vertical, DS.Space.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Toggle Row

struct DSToggleRow: View {
    let icon: String?
    let iconColor: SwiftUI.Color
    let title: String
    @Binding var isOn: Bool
    let onChange: (() -> Void)?

    init(
        _ title: String,
        icon: String? = nil,
        iconColor: SwiftUI.Color = DS.Color.accent,
        isOn: Binding<Bool>,
        onChange: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self._isOn = isOn
        self.onChange = onChange
    }

    var body: some View {
        HStack(spacing: DS.Space.md) {
            if let icon {
                iconView(icon, color: iconColor)
            }

            Text(title)
                .font(DS.Typography.listTitle)
                .foregroundStyle(DS.Color.textPrimary)

            Spacer(minLength: 0)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(DS.Color.accent)
                .onChange(of: isOn) { _, _ in
                    DS.Haptic.softTap()
                    onChange?()
                }
        }
        .padding(.vertical, DS.Space.sm)
    }
}

// MARK: - Value Row (read-only display)

struct DSValueRow: View {
    let icon: String?
    let iconColor: SwiftUI.Color
    let title: String
    let value: String

    init(
        _ title: String,
        value: String,
        icon: String? = nil,
        iconColor: SwiftUI.Color = DS.Color.accent
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.iconColor = iconColor
    }

    var body: some View {
        HStack(spacing: DS.Space.md) {
            if let icon {
                iconView(icon, color: iconColor)
            }

            Text(title)
                .font(DS.Typography.listTitle)
                .foregroundStyle(DS.Color.textPrimary)

            Spacer(minLength: 0)

            Text(value)
                .font(DS.Typography.footnote)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .padding(.vertical, DS.Space.sm)
    }
}

// MARK: - Stepper Row

struct DSStepperRow: View {
    let title: String
    let icon: String?
    let iconColor: SwiftUI.Color
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String
    let onChange: (() -> Void)?

    init(
        _ title: String,
        value: Binding<Int>,
        range: ClosedRange<Int> = -30...30,
        unit: String = "",
        icon: String? = nil,
        iconColor: SwiftUI.Color = DS.Color.accent,
        onChange: (() -> Void)? = nil
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.unit = unit
        self.icon = icon
        self.iconColor = iconColor
        self.onChange = onChange
    }

    var body: some View {
        HStack(spacing: DS.Space.md) {
            if let icon {
                iconView(icon, color: iconColor)
            }

            Text(title)
                .font(DS.Typography.listTitle)
                .foregroundStyle(DS.Color.textPrimary)

            Spacer(minLength: 0)

            Text(unit.isEmpty ? "\(value)" : "\(value) \(unit)")
                .font(DS.Typography.bodyMedium)
                .foregroundStyle(DS.Color.accent)
                .monospacedDigit()
                .frame(minWidth: 36, alignment: .trailing)

            HStack(spacing: 0) {
                stepperButton(icon: "minus", enabled: value > range.lowerBound) {
                    value -= 1
                    DS.Haptic.softTap()
                    onChange?()
                }

                Rectangle()
                    .fill(DS.Color.hairline)
                    .frame(width: 1, height: 20)

                stepperButton(icon: "plus", enabled: value < range.upperBound) {
                    value += 1
                    DS.Haptic.softTap()
                    onChange?()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                    .fill(DS.Color.accentSoft)
            )
        }
        .padding(.vertical, DS.Space.sm)
    }

    private func stepperButton(icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            guard enabled else { return }
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(enabled ? DS.Color.accent : DS.Color.textTertiary)
                .frame(width: 36, height: 32)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

// MARK: - Shared Icon View

private func iconView(_ name: String, color: SwiftUI.Color) -> some View {
    Image(systemName: name)
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(color)
        .frame(width: 30, height: 30)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                .fill(color.opacity(0.12))
        )
}

// MARK: - Previews

#Preview("DSListRow") {
    DSCard {
        VStack(spacing: 0) {
            DSListRow("Hakkında", icon: "info.circle", subtitle: "Sürüm 1.0")
            Hairline()
            DSListRow("Gizlilik", icon: "lock.shield", trailing: "Aktif")
        }
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}

#Preview("DSToggleRow") {
    struct Preview: View {
        @State private var isOn = true
        var body: some View {
            DSCard {
                DSToggleRow("Sabah Bildirimi", icon: "sun.horizon", isOn: $isOn)
            }
            .padding(DS.Space.lg)
            .background(DS.Color.backgroundPrimary)
        }
    }
    return Preview()
}

#Preview("DSStepperRow") {
    struct Preview: View {
        @State private var value = 5
        var body: some View {
            DSCard {
                DSStepperRow("Fajr Offset", value: $value, unit: "dk", icon: "sun.horizon")
            }
            .padding(DS.Space.lg)
            .background(DS.Color.backgroundPrimary)
        }
    }
    return Preview()
}

#Preview("DSValueRow") {
    DSCard {
        DSValueRow("Sürüm", value: "1.2.0", icon: "app.badge")
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
