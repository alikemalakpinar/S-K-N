import SwiftUI
import SwiftData

/// Lightweight wrapper that provides a `DependencyContainer` + `modelContainer`
/// for SwiftUI Previews. The container gracefully falls back to noop stubs
/// when the static DB isn't available.
///
/// Usage:
/// ```swift
/// #Preview { DSPreview { c in DashboardView(container: c) } }
/// ```
struct DSPreview<Content: View>: View {
    private let container: DependencyContainer
    @ViewBuilder let content: (DependencyContainer) -> Content

    init(@ViewBuilder content: @escaping (DependencyContainer) -> Content) {
        self.container = DependencyContainer()
        self.content = content
    }

    var body: some View {
        content(container)
            .modelContainer(container.modelContainer)
    }
}
