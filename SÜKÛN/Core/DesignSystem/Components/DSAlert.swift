import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DSAlert — Inline banners, toast notifications
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum DSAlertVariant {
    case info
    case success
    case warning
    case error
}

// MARK: - Inline Alert Banner

struct DSAlert: View {
    let title: String?
    let message: String
    let variant: DSAlertVariant
    let action: (() -> Void)?
    let actionLabel: String?

    init(
        _ message: String,
        title: String? = nil,
        variant: DSAlertVariant = .info,
        actionLabel: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.title = title
        self.variant = variant
        self.actionLabel = actionLabel
        self.action = action
    }

    var body: some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(accentColor)

            VStack(alignment: .leading, spacing: 2) {
                if let title {
                    Text(title)
                        .font(DS.Typography.bodyMedium)
                        .foregroundStyle(DS.Color.textPrimary)
                }

                Text(message)
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            }

            Spacer(minLength: 0)

            if let action, let actionLabel {
                Button {
                    DS.Haptic.softTap()
                    action()
                } label: {
                    Text(actionLabel)
                        .font(DS.Typography.bodyMedium)
                        .foregroundStyle(accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DS.Space.md)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                .fill(accentColor.opacity(0.08))
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                .fill(accentColor)
                .frame(width: 3)
        }
    }

    private var iconName: String {
        switch variant {
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.circle.fill"
        }
    }

    private var accentColor: SwiftUI.Color {
        switch variant {
        case .info: DS.Color.accent
        case .success: DS.Color.success
        case .warning: DS.Color.warning
        case .error: .red
        }
    }
}

// MARK: - Toast (floating notification)

struct DSToast: View {
    let message: String
    let icon: String?
    let variant: DSAlertVariant

    init(
        _ message: String,
        icon: String? = nil,
        variant: DSAlertVariant = .success
    ) {
        self.message = message
        self.icon = icon
        self.variant = variant
    }

    var body: some View {
        HStack(spacing: DS.Space.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(toastColor)
            }

            Text(message)
                .font(DS.Typography.bodyMedium)
                .foregroundStyle(DS.Color.textPrimary)
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.vertical, DS.Space.md)
        .background(
            Capsule()
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
        )
    }

    private var toastColor: SwiftUI.Color {
        switch variant {
        case .info: DS.Color.accent
        case .success: DS.Color.success
        case .warning: DS.Color.warning
        case .error: .red
        }
    }
}

// MARK: - Toast Modifier

extension View {
    func dsToast(
        isPresented: Binding<Bool>,
        message: String,
        icon: String? = "checkmark.circle.fill",
        variant: DSAlertVariant = .success,
        duration: Double = 2.5
    ) -> some View {
        overlay(alignment: .top) {
            if isPresented.wrappedValue {
                DSToast(message, icon: icon, variant: variant)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, DS.Space.x3)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation(DS.Motion.standard) {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
            }
        }
        .animation(DS.Motion.bouncy, value: isPresented.wrappedValue)
    }
}

// MARK: - Previews

#Preview("DSAlert — Variants") {
    VStack(spacing: DS.Space.lg) {
        DSAlert("Bilgilendirme mesajı.", title: "Bilgi", variant: .info)
        DSAlert("İşlem başarılı!", title: "Başarılı", variant: .success)
        DSAlert("Dikkatli olun.", title: "Uyarı", variant: .warning)
        DSAlert("Bir hata oluştu.", title: "Hata", variant: .error, actionLabel: "Tekrar") {}
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}

#Preview("DSToast") {
    VStack(spacing: DS.Space.lg) {
        DSToast("Kaydedildi", icon: "checkmark.circle.fill", variant: .success)
        DSToast("Uyarı", icon: "exclamationmark.triangle.fill", variant: .warning)
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
