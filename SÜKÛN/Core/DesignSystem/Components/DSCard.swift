import SwiftUI

/// Floating card on ivory background with optional glassmorphism.
///
/// Usage:
/// ```swift
/// DSCard { Text("Hello") }                    // Standard elevated card
/// DSCard(.glass) { Text("Frosted") }          // Glassmorphic card
/// DSCard(.glass(.ultraThinMaterial)) { ... }  // Custom material
/// ```
struct DSCard<Content: View>: View {
    enum Style {
        case elevated
        case glass(Material = .thinMaterial)
    }

    let style: Style
    @ViewBuilder let content: () -> Content

    init(_ style: Style = .elevated, @ViewBuilder content: @escaping () -> Content) {
        self.style = style
        self.content = content
    }

    var body: some View {
        content()
            .padding(DS.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                switch style {
                case .elevated:
                    RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                        .fill(DS.Color.cardElevated)
                        .overlay(
                            // Top-edge light catch — simulates ambient light reflection
                            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.08), .clear, .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                case .glass(let material):
                    RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                        .fill(material)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                                .stroke(DS.Color.glassBorder, lineWidth: 0.5)
                        )
                }
            }
    }
}

// MARK: - Previews

#Preview("DSCard") {
    VStack(spacing: DS.Space.lg) {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                Text("Elevated Card")
                    .font(DS.Typography.headline)
                    .foregroundStyle(DS.Color.textPrimary)
                Text("Default elevated style with shadow.")
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }

        DSCard(.glass()) {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                Text("Glass Card")
                    .font(DS.Typography.headline)
                    .foregroundStyle(DS.Color.textPrimary)
                Text("Glassmorphic style with thin material.")
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
