import SwiftUI

/// A 1px accent line that animates "fill" left→right.
/// Used under active verse or active preset.
struct AccentUnderline: View {
    var active: Bool

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(DS.Color.accent)
                .frame(width: active ? geo.size.width : 0, height: 1)
                .animation(.easeOut(duration: 0.5), value: active)
        }
        .frame(height: 1)
    }
}

// MARK: - Preview

#Preview("AccentUnderline") {
    VStack(spacing: DS.Space.xl) {
        VStack(spacing: DS.Space.sm) {
            Text("Active").foregroundStyle(DS.Color.textPrimary)
            AccentUnderline(active: true)
        }
        VStack(spacing: DS.Space.sm) {
            Text("Inactive").foregroundStyle(DS.Color.textSecondary)
            AccentUnderline(active: false)
        }
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
