import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DSSegmentedControl — Custom segmented control with DS styling
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct DSSegmentedControl<T: Hashable>: View {
    let options: [T]
    @Binding var selected: T
    let label: (T) -> String
    let onChange: ((T) -> Void)?

    @Namespace private var ns

    init(
        _ options: [T],
        selected: Binding<T>,
        label: @escaping (T) -> String,
        onChange: ((T) -> Void)? = nil
    ) {
        self.options = options
        self._selected = selected
        self.label = label
        self.onChange = onChange
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selected

                Button {
                    guard !isSelected else { return }
                    DS.Haptic.softTap()
                    withAnimation(DS.Motion.tap) {
                        selected = option
                    }
                    onChange?(option)
                } label: {
                    Text(label(option))
                        .font(DS.Typography.bodyMedium)
                        .foregroundStyle(isSelected ? DS.Color.textPrimary : DS.Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Space.sm + 2)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: DS.Radius.sm - 2, style: .continuous)
                                    .fill(DS.Color.cardElevated)
                                    .dsShadow(DS.Shadow.premiumCard)
                                    .matchedGeometryEffect(id: "seg", in: ns)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                .fill(DS.Color.accentSoft)
        )
    }
}

// MARK: - String-based convenience

extension DSSegmentedControl where T == String {
    init(
        _ options: [String],
        selected: Binding<String>,
        onChange: ((String) -> Void)? = nil
    ) {
        self.init(options, selected: selected, label: { $0 }, onChange: onChange)
    }
}

// MARK: - Previews

#Preview("DSSegmentedControl") {
    struct Preview: View {
        @State private var selected = "Sistem"
        var body: some View {
            VStack(spacing: DS.Space.xl) {
                DSSegmentedControl(
                    ["Sistem", "Açık", "Koyu"],
                    selected: $selected,
                    label: { $0 }
                )

                Text("Seçili: \(selected)")
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .padding(DS.Space.lg)
            .background(DS.Color.backgroundPrimary)
        }
    }
    return Preview()
}
