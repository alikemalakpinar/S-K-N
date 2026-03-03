import SwiftUI

/// A 1px separator line using DS tokens.
struct Hairline: View {
    var accent: Bool = false

    var body: some View {
        Rectangle()
            .fill(accent ? DS.Color.accent : DS.Color.hairline)
            .frame(height: 1 / UIScreen.main.scale)
    }
}
