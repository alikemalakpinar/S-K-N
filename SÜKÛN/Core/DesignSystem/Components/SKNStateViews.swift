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

    var body: some View {
        VStack(spacing: DS.Space.lg) {
            ProgressView()
                .tint(DS.Color.accent)
                .controlSize(.regular)

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

    var body: some View {
        VStack(spacing: DS.Space.lg) {
            ZStack {
                Circle()
                    .fill(DS.Color.accentSoft)
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(DS.Color.accent)
            }

            VStack(spacing: DS.Space.sm) {
                Text(title)
                    .font(DS.Typography.headline)
                    .foregroundStyle(DS.Color.textPrimary)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(DS.Typography.caption)
                        .foregroundStyle(DS.Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, DS.Space.x2)

            if let action, let actionLabel {
                Button {
                    DS.Haptic.softTap()
                    action()
                } label: {
                    Text(actionLabel)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, DS.Space.x2)
                        .padding(.vertical, DS.Space.md)
                        .background(
                            Capsule().fill(DS.Color.accent)
                        )
                }
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

    var body: some View {
        VStack(spacing: DS.Space.lg) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.08))
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(.red.opacity(0.7))
            }

            VStack(spacing: DS.Space.sm) {
                Text(title)
                    .font(DS.Typography.headline)
                    .foregroundStyle(DS.Color.textPrimary)

                Text(message)
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, DS.Space.x2)

            if let retryAction {
                Button {
                    DS.Haptic.softTap()
                    retryAction()
                } label: {
                    Label("Tekrar Dene", systemImage: "arrow.clockwise")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, DS.Space.x2)
                        .padding(.vertical, DS.Space.md)
                        .background(
                            Capsule().fill(DS.Color.accent)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}
