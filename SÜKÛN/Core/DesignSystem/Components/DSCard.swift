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
