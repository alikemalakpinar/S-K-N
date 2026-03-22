import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DSButton — Unified button component
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum DSButtonStyle {
    case primary        // accent fill, white text, shadow glow
    case secondary      // accent border, accent text, transparent
    case ghost          // no border, accent text only
    case destructive    // red accent
}

enum DSButtonSize {
    case large          // 56pt height
    case medium         // 48pt height
    case small          // 40pt height
}

struct DSButton: View {
    let title: String
    let icon: String?
    let style: DSButtonStyle
    let size: DSButtonSize
    let isLoading: Bool
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        style: DSButtonStyle = .primary,
        size: DSButtonSize = .large,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button {
            guard !isLoading else { return }
            DS.Haptic.softTap()
            action()
        } label: {
            HStack(spacing: DS.Space.sm) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.9)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: iconSize, weight: .medium))
                    }
                    Text(title)
                        .font(.system(size: fontSize, weight: .semibold))
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(backgroundView)
            .overlay(borderView)
        }
        .buttonStyle(DSButtonPressStyle())
        .opacity(isLoading ? 0.85 : 1)
    }

    // MARK: - Style Properties

    private var height: CGFloat {
        switch size {
        case .large: 56
        case .medium: 48
        case .small: 40
        }
    }

    private var fontSize: CGFloat {
        switch size {
        case .large: 17
        case .medium: 15
        case .small: 14
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .large: 16
        case .medium: 14
        case .small: 13
        }
    }

    private var foregroundColor: SwiftUI.Color {
        switch style {
        case .primary: .white
        case .secondary: DS.Color.accent
        case .ghost: DS.Color.accent
        case .destructive: .white
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DS.Color.accent, DS.Color.accent.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: DS.Color.accent.opacity(0.35), radius: 14, y: 6)
        case .secondary:
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(.clear)
        case .ghost:
            Color.clear
        case .destructive:
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(.red)
                .shadow(color: .red.opacity(0.2), radius: 12, y: 4)
        }
    }

    @ViewBuilder
    private var borderView: some View {
        switch style {
        case .secondary:
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(DS.Color.accent, lineWidth: 1.5)
        default:
            EmptyView()
        }
    }
}

// MARK: - Icon-Only Button

struct DSIconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    init(_ icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    var body: some View {
        Button {
            DS.Haptic.softTap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.34, weight: .medium))
                .foregroundStyle(DS.Color.textSecondary)
                .frame(width: size, height: size)
                .background(Circle().fill(DS.Color.cardElevated))
        }
        .buttonStyle(DSButtonPressStyle())
    }
}

// MARK: - Press Style

private struct DSButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsPress(configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("DSButton — Styles") {
    VStack(spacing: DS.Space.lg) {
        DSButton("Primary", icon: "star.fill") {}
        DSButton("Secondary", icon: "bell", style: .secondary) {}
        DSButton("Ghost", style: .ghost) {}
        DSButton("Destructive", icon: "trash", style: .destructive) {}
        DSButton("Loading…", style: .primary, isLoading: true) {}
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}

#Preview("DSButton — Sizes") {
    VStack(spacing: DS.Space.lg) {
        DSButton("Large", size: .large) {}
        DSButton("Medium", size: .medium) {}
        DSButton("Small", size: .small) {}
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}

#Preview("DSIconButton") {
    HStack(spacing: DS.Space.lg) {
        DSIconButton("xmark") {}
        DSIconButton("gear") {}
        DSIconButton("heart.fill") {}
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
