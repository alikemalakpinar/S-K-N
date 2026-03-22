import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DSSkeleton — Shimmer loading placeholder
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct DSSkeleton: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    @State private var shimmerOffset: CGFloat = -1

    init(
        width: CGFloat? = nil,
        height: CGFloat = 16,
        cornerRadius: CGFloat = DS.Radius.sm
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(DS.Color.hairline)
            .frame(width: width, height: height)
            .overlay {
                GeometryReader { geo in
                    let gradientWidth = geo.size.width * 0.6
                    LinearGradient(
                        colors: [
                            .clear,
                            DS.Color.cardElevated.opacity(0.5),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: gradientWidth)
                    .offset(x: shimmerOffset * (geo.size.width + gradientWidth) - gradientWidth / 2)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.4)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerOffset = 1
                }
            }
    }
}

// MARK: - Preset Skeletons

extension DSSkeleton {
    /// Card-shaped skeleton — dashboard widget placeholder
    static func card(height: CGFloat = 120) -> some View {
        DSSkeleton(height: height, cornerRadius: DS.Radius.lg)
    }

    /// Text line skeleton — single line placeholder
    static func line(width: CGFloat = 160) -> some View {
        DSSkeleton(width: width, height: 14)
    }

    /// Circle skeleton — avatar or icon placeholder
    static func circle(size: CGFloat = 44) -> some View {
        DSSkeleton(width: size, height: size, cornerRadius: size / 2)
    }
}

// MARK: - Skeleton Group (list placeholder)

struct DSSkeletonGroup: View {
    let rows: Int

    init(rows: Int = 4) {
        self.rows = rows
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            ForEach(0..<rows, id: \.self) { i in
                HStack(spacing: DS.Space.md) {
                    DSSkeleton.circle(size: 36)
                    VStack(alignment: .leading, spacing: DS.Space.sm) {
                        DSSkeleton.line(width: CGFloat.random(in: 100...180))
                        DSSkeleton.line(width: CGFloat.random(in: 60...120))
                    }
                }
                .dsAppear(loaded: true, index: i)
            }
        }
        .padding(DS.Space.lg)
    }
}

// MARK: - Previews

#Preview("DSSkeleton") {
    VStack(alignment: .leading, spacing: DS.Space.lg) {
        DSSkeleton.card(height: 100)
        DSSkeleton.line(width: 200)
        DSSkeleton.line(width: 140)
        HStack(spacing: DS.Space.md) {
            DSSkeleton.circle(size: 44)
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                DSSkeleton.line(width: 160)
                DSSkeleton.line(width: 100)
            }
        }
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}

#Preview("DSSkeletonGroup") {
    DSSkeletonGroup(rows: 4)
        .background(DS.Color.backgroundPrimary)
}
