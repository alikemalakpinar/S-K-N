import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN — Reusable State Views
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  Three standardised views for empty, error, and loading states.
//  Use these instead of ad-hoc inline implementations to maintain
//  visual consistency across the app.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MARK: - Loading State

/// A centered loading spinner with optional message.
///
/// Usage:
/// ```swift
/// if viewModel.isLoading {
///     SKNLoadingState()
/// }
/// ```
struct SKNLoadingState: View {
    var message: String = "Yükleniyor..."
    var useSkeleton: Bool = false

    var body: some View {
        VStack(spacing: DS.Space.lg) {
            if useSkeleton {
                SkeletonShimmerGroup(rows: 3)
                    .frame(maxWidth: 260)
            } else {
                SKNLottieView.looping("loading-spin", speed: 1.2)
                    .frame(width: 48, height: 48)
            }

            Text(message)
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

// MARK: - Empty State

/// A centered placeholder for screens with no content.
///
/// Usage:
/// ```swift
/// if items.isEmpty {
///     SKNEmptyState(
///         icon: "book.closed",
///         title: "Henüz Kayıt Yok",
///         message: "Okumaya başladığınızda burada görünecek."
///     )
/// }
/// ```
struct SKNEmptyState: View {
    var icon: String = "tray"
    var title: String
    var message: String?
    var action: (() -> Void)?
    var actionLabel: String?
    /// Optional Lottie animation name to replace the SF Symbol icon
    var lottieAnimation: String?

    @State private var floating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: DS.Space.xl) {
            Group {
                if let lottieAnimation {
                    SKNLottieView.looping(lottieAnimation, speed: 0.8)
                        .frame(width: 120, height: 120)
                } else {
                    ZStack {
                        Circle()
                            .fill(DS.Color.accentSoft)
                            .frame(width: 88, height: 88)
                        Image(systemName: icon)
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(DS.Color.accent)
                    }
                }
            }
            .offset(y: floating ? -6 : 0)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                value: floating
            )
            .onAppear {
                if !reduceMotion { floating = true }
            }

            VStack(spacing: DS.Space.sm) {
                Text(title)
                    .font(DS.Typography.displayBody)
                    .foregroundStyle(DS.Color.textPrimary)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(DS.Typography.footnote)
                        .foregroundStyle(DS.Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, DS.Space.x2)

            if let action, let actionLabel {
                DSButton(actionLabel, style: .secondary, size: .medium) {
                    action()
                }
                .padding(.horizontal, DS.Space.x4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message ?? "")")
    }
}

// MARK: - Error State

/// A centered error message with optional retry action.
///
/// Usage:
/// ```swift
/// if let error = viewModel.errorMessage {
///     SKNErrorState(message: error) {
///         viewModel.retry()
///     }
/// }
/// ```
struct SKNErrorState: View {
    var icon: String = "exclamationmark.triangle"
    var title: String = "Bir Hata Oluştu"
    var message: String
    var retryAction: (() -> Void)?

    @State private var floating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: DS.Space.xl) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.08))
                    .frame(width: 88, height: 88)
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.red.opacity(0.7))
            }
            .offset(y: floating ? -6 : 0)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                value: floating
            )
            .onAppear {
                if !reduceMotion { floating = true }
            }

            VStack(spacing: DS.Space.sm) {
                Text(title)
                    .font(DS.Typography.displayBody)
                    .foregroundStyle(DS.Color.textPrimary)

                Text(message)
                    .font(DS.Typography.footnote)
                    .foregroundStyle(DS.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, DS.Space.x2)

            if let retryAction {
                DSButton("Tekrar Dene", icon: "arrow.clockwise", style: .secondary, size: .medium) {
                    retryAction()
                }
                .padding(.horizontal, DS.Space.x4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

// MARK: - Previews

#Preview("SKNLoadingState") {
    SKNLoadingState()
        .background(DS.Color.backgroundPrimary)
}

#Preview("SKNEmptyState") {
    SKNEmptyState(
        icon: "book.closed",
        title: "Henüz Kayıt Yok",
        message: "Okumaya başladığınızda burada görünecek.",
        action: {},
        actionLabel: "Başla"
    )
    .background(DS.Color.backgroundPrimary)
}

#Preview("SKNErrorState") {
    SKNErrorState(
        message: "Veriler yüklenemedi. Lütfen tekrar deneyin.",
        retryAction: {}
    )
    .background(DS.Color.backgroundPrimary)
}
