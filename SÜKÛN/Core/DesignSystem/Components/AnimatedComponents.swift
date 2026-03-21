import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Animated Components — Reusable interactive elements
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MARK: - Interactive Button

/// Button with press → scale(0.95) and bouncy spring release.
struct InteractiveButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}

private struct InteractiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(
                configuration.isPressed
                    ? DS.Motion.tap
                    : DS.Motion.bouncy,
                value: configuration.isPressed
            )
    }
}

// MARK: - Animated Card

/// Card wrapper with PhaseAnimator entrance (opacity → scale → settle).
/// Wraps content in standard DS card styling with animated entrance.
struct AnimatedCard<Content: View>: View {
    let trigger: Bool
    let index: Int
    @ViewBuilder let content: () -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(trigger: Bool, index: Int = 0, @ViewBuilder content: @escaping () -> Content) {
        self.trigger = trigger
        self.index = index
        self.content = content
    }

    var body: some View {
        content()
            .padding(DS.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(DS.Color.cardElevated)
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            )
            .opacity(trigger ? 1 : 0)
            .offset(y: trigger ? 0 : 16)
            .scaleEffect(trigger ? 1.0 : 0.96)
            .animation(
                reduceMotion
                    ? .easeOut(duration: 0.15)
                    : DS.Motion.standard.delay(Double(index) * 0.08),
                value: trigger
            )
    }
}

// MARK: - Skeleton Shimmer

/// Animated gradient sweep shimmer for loading states.
/// Replaces standard ProgressView with a premium shimmer effect.
struct SkeletonShimmer: View {
    var width: CGFloat = .infinity
    var height: CGFloat = 16
    var cornerRadius: CGFloat = 8
    @State private var phase: CGFloat = -1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(DS.Color.hairline)
            .frame(maxWidth: width == .infinity ? .infinity : nil)
            .frame(width: width == .infinity ? nil : width, height: height)
            .overlay(
                GeometryReader { geo in
                    if !reduceMotion {
                        LinearGradient(
                            colors: [
                                .clear,
                                DS.Color.textTertiary.opacity(0.08),
                                DS.Color.textTertiary.opacity(0.15),
                                DS.Color.textTertiary.opacity(0.08),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: phase * geo.size.width)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.5
                }
            }
    }
}

/// A group of skeleton shimmer rows for content loading.
struct SkeletonShimmerGroup: View {
    let rows: Int

    init(rows: Int = 3) {
        self.rows = rows
    }

    var body: some View {
        VStack(spacing: DS.Space.lg) {
            ForEach(0..<rows, id: \.self) { _ in
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    SkeletonShimmer(width: .infinity, height: 14)
                    SkeletonShimmer(width: 180, height: 10)
                    SkeletonShimmer(width: 120, height: 10)
                }
                .padding(DS.Space.lg)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                        .fill(DS.Color.cardElevated)
                )
            }
        }
    }
}

// MARK: - Ripple Circle

/// Single outward-expanding ring triggered by a counter value.
struct RippleCircle: View {
    let trigger: Int
    var color: Color = DS.Color.accent

    @State private var ripples: [RippleState] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(color.opacity(ripple.opacity), lineWidth: 1.5)
                    .scaleEffect(ripple.scale)
            }
        }
        .onChange(of: trigger) { _, _ in
            guard !reduceMotion else { return }
            let ripple = RippleState()
            ripples.append(ripple)

            withAnimation(DS.Motion.ripple) {
                if let idx = ripples.firstIndex(where: { $0.id == ripple.id }) {
                    ripples[idx].scale = 2.0
                    ripples[idx].opacity = 0
                }
            }

            // Clean up
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.0))
                ripples.removeAll { $0.id == ripple.id }
            }
        }
    }
}

private struct RippleState: Identifiable {
    let id = UUID()
    var scale: CGFloat = 0.8
    var opacity: Double = 0.6
}

// MARK: - Previews

#Preview("InteractiveButton") {
    InteractiveButton {
        print("tapped")
    } label: {
        Text("Tap Me")
            .font(DS.Typography.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, DS.Space.x2)
            .padding(.vertical, DS.Space.md)
            .background(Capsule().fill(DS.Color.accent))
    }
}

#Preview("AnimatedCard") {
    struct CardPreview: View {
        @State private var shown = false
        var body: some View {
            VStack(spacing: DS.Space.lg) {
                AnimatedCard(trigger: shown, index: 0) {
                    Text("Card 1").font(DS.Typography.headline)
                }
                AnimatedCard(trigger: shown, index: 1) {
                    Text("Card 2").font(DS.Typography.headline)
                }
                Button("Show") { shown = true }
            }
            .padding(DS.Space.lg)
            .background(DS.Color.backgroundPrimary)
        }
    }
    return CardPreview()
}

#Preview("SkeletonShimmer") {
    SkeletonShimmerGroup(rows: 3)
        .padding(DS.Space.lg)
        .background(DS.Color.backgroundPrimary)
}
