import SwiftUI

/// A 1px separator line using DS tokens.
/// Set `shimmer: true` for an animated gold-sweep effect.
struct Hairline: View {
    var accent: Bool = false
    var shimmer: Bool = false

    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        Rectangle()
            .fill(accent ? DS.Color.accent : DS.Color.hairline)
            .frame(height: 1 / UIScreen.main.scale)
            .overlay {
                if shimmer {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        DS.Color.accent.opacity(0.35),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * 0.4)
                            .offset(x: shimmerOffset * geo.size.width)
                            .onAppear {
                                withAnimation(
                                    .linear(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                                ) {
                                    shimmerOffset = 1.2
                                }
                            }
                    }
                    .clipped()
                }
            }
    }
}

// MARK: - Preview

#Preview("Hairline") {
    VStack(spacing: DS.Space.lg) {
        Text("Above").foregroundStyle(DS.Color.textPrimary)
        Hairline()
        Text("Default").foregroundStyle(DS.Color.textSecondary)
        Hairline(accent: true)
        Text("Accent").foregroundStyle(DS.Color.textSecondary)
        Hairline(accent: true, shimmer: true)
        Text("Shimmer").foregroundStyle(DS.Color.textSecondary)
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
