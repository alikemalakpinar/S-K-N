import SwiftUI
import SwiftData

@main
struct SU_KU_NApp: App {
    @State private var container = DependencyContainer()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Query(FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" }))
    private var userSettings: [UserSetting]

    private var resolvedColorScheme: ColorScheme? {
        guard let theme = userSettings.first?.theme else { return nil }
        switch theme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private var fontScale: Double {
        userSettings.first?.fontScale ?? 1.0
    }

    var body: some Scene {
        WindowGroup {
            Group {
                SplashGateView(container: container, hasCompletedOnboarding: $hasCompletedOnboarding)
            }
            .background(DS.Color.backgroundPrimary)
            .preferredColorScheme(resolvedColorScheme)
            .environment(\.dsFontScale, fontScale)
        }
        .modelContainer(container.modelContainer)
    }
}
