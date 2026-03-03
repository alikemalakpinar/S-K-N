import SwiftUI
import SwiftData

@main
struct SU_KU_NApp: App {
    @State private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .background(DS.Color.backgroundPrimary)
                .preferredColorScheme(.dark)
        }
        .modelContainer(container.modelContainer)
    }
}
