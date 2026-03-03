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
