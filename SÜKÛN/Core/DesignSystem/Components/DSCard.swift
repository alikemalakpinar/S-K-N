import SwiftUI

/// Floating white card on ivory background.
struct DSCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(DS.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DS.Color.cardElevated)
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            )
    }
}
