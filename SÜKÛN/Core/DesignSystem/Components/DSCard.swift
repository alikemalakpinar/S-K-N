import SwiftUI

/// Minimal card used on Dashboard:
/// backgroundSecondary, cornerRadius 16, padding 16, subtle shadow.
struct DSCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(DS.Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.Color.backgroundSecondary, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}
