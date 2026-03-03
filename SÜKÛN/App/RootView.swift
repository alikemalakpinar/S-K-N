import SwiftUI

struct RootView: View {
    let container: DependencyContainer

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                DashboardView(container: container)
            }

            Tab("Prayer", systemImage: "clock.fill") {
                PrayerTimesView(container: container)
            }

            Tab("Quran", systemImage: "book.fill") {
                QuranView(container: container)
            }

            Tab("Dhikr", systemImage: "circle.circle.fill") {
                DhikrView(container: container)
            }

            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView(container: container)
            }
        }
        .tint(DS.Color.accent)
    }
}
