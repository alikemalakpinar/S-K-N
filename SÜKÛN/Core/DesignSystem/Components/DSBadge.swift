import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DSBadge — Status indicator, pill labels, counters
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum DSBadgeVariant {
    case accent      // gold fill
    case success     // green fill
    case warning     // amber fill
    case subtle      // muted background
    case outline     // border only
}

struct DSBadge: View {
    let text: String
    let icon: String?
    let variant: DSBadgeVariant

    init(
        _ text: String,
        icon: String? = nil,
        variant: DSBadgeVariant = .accent
    ) {
        self.text = text
        self.icon = icon
        self.variant = variant
    }

    var body: some View {
        HStack(spacing: DS.Space.xs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
            }

            Text(text)
                .font(DS.Typography.chipLabel)
                .tracking(0.5)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, DS.Space.sm + 2)
        .padding(.vertical, DS.Space.xs + 1)
        .background(backgroundView)
    }

    private var foregroundColor: SwiftUI.Color {
        switch variant {
        case .accent: .white
        case .success: .white
        case .warning: .white
        case .subtle: DS.Color.textSecondary
        case .outline: DS.Color.accent
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch variant {
        case .accent:
            Capsule()
                .fill(DS.Color.accent)
        case .success:
            Capsule()
                .fill(DS.Color.success)
        case .warning:
            Capsule()
                .fill(DS.Color.warning)
        case .subtle:
            Capsule()
                .fill(DS.Color.accentSoft)
        case .outline:
            Capsule()
                .stroke(DS.Color.accent, lineWidth: 1)
        }
    }
}

// MARK: - Notification Dot

struct DSNotificationDot: View {
    let color: SwiftUI.Color

    init(_ color: SwiftUI.Color = .red) {
        self.color = color
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
    }
}

// MARK: - Previews

#Preview("DSBadge — Variants") {
    HStack(spacing: DS.Space.md) {
        DSBadge("Yeni", icon: "sparkles", variant: .accent)
        DSBadge("Aktif", variant: .success)
        DSBadge("Uyarı", variant: .warning)
        DSBadge("Mekki", variant: .subtle)
        DSBadge("Medeni", variant: .outline)
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}

#Preview("DSNotificationDot") {
    HStack(spacing: DS.Space.xl) {
        DSNotificationDot()
        DSNotificationDot(DS.Color.accent)
        DSNotificationDot(DS.Color.success)
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
