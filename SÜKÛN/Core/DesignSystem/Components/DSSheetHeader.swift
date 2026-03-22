import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DSSheetHeader — Consistent sheet/modal header with drag handle
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct DSSheetHeader: View {
    let title: String
    let subtitle: String?
    let trailing: AnyView?
    let onDismiss: (() -> Void)?

    init(
        _ title: String,
        subtitle: String? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = nil
        self.onDismiss = onDismiss
    }

    init<Trailing: View>(
        _ title: String,
        subtitle: String? = nil,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = AnyView(trailing())
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(DS.Color.hairline)
                .frame(width: 36, height: 4)
                .padding(.top, DS.Space.sm)
                .padding(.bottom, DS.Space.md)

            HStack {
                // Close button
                if let onDismiss {
                    DSIconButton("xmark", size: 32) {
                        onDismiss()
                    }
                }

                VStack(alignment: onDismiss != nil ? .leading : .center, spacing: 2) {
                    Text(title)
                        .font(DS.Typography.headline)
                        .foregroundStyle(DS.Color.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: onDismiss != nil ? .leading : .center)

                if let trailing {
                    trailing
                }
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.bottom, DS.Space.md)

            Hairline()
        }
    }
}

// MARK: - Previews

#Preview("DSSheetHeader") {
    VStack(spacing: 0) {
        DSSheetHeader("Ayet Detayı", subtitle: "Sure 2, Ayet 255", onDismiss: {})
        Spacer()
    }
    .background(DS.Color.backgroundPrimary)
}

#Preview("DSSheetHeader — Trailing") {
    VStack(spacing: 0) {
        DSSheetHeader("Ayarlar", onDismiss: {}) {
            DSIconButton("gear", size: 32) {}
        }
        Spacer()
    }
    .background(DS.Color.backgroundPrimary)
}
