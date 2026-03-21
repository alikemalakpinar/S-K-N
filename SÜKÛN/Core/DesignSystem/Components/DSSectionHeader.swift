import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DSSectionHeader — Consistent section header with optional action
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct DSSectionHeader: View {
    let title: String
    let serif: Bool
    let actionLabel: String?
    let action: (() -> Void)?

    init(
        _ title: String,
        serif: Bool = false,
        actionLabel: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.serif = serif
        self.actionLabel = actionLabel
        self.action = action
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(serif ? DS.Typography.displayBody : DS.Typography.headline)
                .foregroundStyle(DS.Color.textPrimary)

            Spacer()

            if let actionLabel, let action {
                Button {
                    DS.Haptic.softTap()
                    action()
                } label: {
                    Text(actionLabel)
                        .font(DS.Typography.footnote)
                        .foregroundStyle(DS.Color.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.top, DS.Space.xl)
        .padding(.bottom, DS.Space.sm)
    }
}

// MARK: - Form Section Header (replaces Section { } header: pattern)

struct DSFormSectionHeader: View {
    let title: String
    let icon: String?

    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: DS.Space.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DS.Color.accent)
            }

            Text(title.uppercased())
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(0.8)
        }
    }
}

// MARK: - Previews

#Preview("DSSectionHeader") {
    VStack(alignment: .leading, spacing: 0) {
        DSSectionHeader("Namaz Vakitleri", serif: true)
        DSSectionHeader("Ayarlar", actionLabel: "Tümü") {}
        DSSectionHeader("Zikir Geçmişi", serif: true, actionLabel: "Detay") {}
    }
    .background(DS.Color.backgroundPrimary)
}

#Preview("DSFormSectionHeader") {
    VStack(alignment: .leading, spacing: DS.Space.lg) {
        DSFormSectionHeader("Günün Namazları", icon: "sun.max")
        DSFormSectionHeader("Hesaplama Yöntemi")
        DSFormSectionHeader("Bildirimler", icon: "bell")
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
