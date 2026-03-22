import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DSProgressBar — Linear & circular progress indicators
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MARK: - Linear Progress

struct DSProgressBar: View {
    let progress: Double // 0.0 ... 1.0
    let height: CGFloat
    let showLabel: Bool
    let color: SwiftUI.Color

    init(
        _ progress: Double,
        height: CGFloat = 6,
        showLabel: Bool = false,
        color: SwiftUI.Color = DS.Color.accent
    ) {
        self.progress = min(max(progress, 0), 1)
        self.height = height
        self.showLabel = showLabel
        self.color = color
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: DS.Space.xs) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                        .fill(DS.Color.hairline)

                    RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                        .fill(color)
                        .frame(width: geo.size.width * progress)
                        .animation(DS.Motion.standard, value: progress)
                }
            }
            .frame(height: height)

            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
                    .monospacedDigit()
            }
        }
        .accessibilityValue("\(Int(progress * 100)) yüzde")
    }
}

// MARK: - Circular Progress

struct DSCircularProgress: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: SwiftUI.Color
    let showLabel: Bool

    init(
        _ progress: Double,
        size: CGFloat = 64,
        lineWidth: CGFloat = 5,
        color: SwiftUI.Color = DS.Color.accent,
        showLabel: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
        self.showLabel = showLabel
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(DS.Color.hairline, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

            // Fill
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(DS.Motion.standard, value: progress)

            if showLabel {
                Text("\(Int(progress * 100))")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Color.textPrimary)
                    .monospacedDigit()
            }
        }
        .frame(width: size, height: size)
        .accessibilityValue("\(Int(progress * 100)) yüzde")
    }
}

// MARK: - Previews

#Preview("DSProgressBar") {
    VStack(spacing: DS.Space.xl) {
        DSProgressBar(0.3)
        DSProgressBar(0.65, showLabel: true)
        DSProgressBar(0.9, height: 10, showLabel: true, color: DS.Color.success)
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}

#Preview("DSCircularProgress") {
    HStack(spacing: DS.Space.xl) {
        DSCircularProgress(0.25)
        DSCircularProgress(0.6, color: DS.Color.success)
        DSCircularProgress(1.0, size: 80, lineWidth: 8, color: .cyan)
    }
    .padding(DS.Space.lg)
    .background(DS.Color.backgroundPrimary)
}
