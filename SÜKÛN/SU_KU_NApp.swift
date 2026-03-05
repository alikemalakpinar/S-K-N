import SwiftUI
import SwiftData

@main
struct SU_KU_NApp: App {
    @State private var container = DependencyContainer()
    @Query(FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" }))
    private var userSettings: [UserSetting]

    private var resolvedColorScheme: ColorScheme? {
        guard let theme = userSettings.first?.theme else { return nil }
        switch theme {
        case "light": return .light
        case "dark": return .dark
        default: return nil // "system" → follow device setting
        }
    }

    private var fontScale: Double {
        userSettings.first?.fontScale ?? 1.0
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .background(DS.Color.backgroundPrimary)
                .preferredColorScheme(resolvedColorScheme)
                .environment(\.dsFontScale, fontScale)
        }
        .modelContainer(container.modelContainer)
    }
}
