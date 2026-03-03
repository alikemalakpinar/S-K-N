import SwiftUI

struct RootView: View {
    let container: DependencyContainer
    @State private var selectedTab = 0
    @State private var quranSegment: QuranSegment = .mushaf

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                DashboardView(container: container, onOpenRehber: openRehber)
            }

            Tab("Prayer", systemImage: "clock.fill", value: 1) {
                PrayerTimesView(container: container)
            }

            Tab("Quran", systemImage: "book.fill", value: 2) {
                QuranView(container: container, selectedSegment: $quranSegment)
            }

            Tab("Dhikr", systemImage: "circle.circle.fill", value: 3) {
                DhikrView(container: container)
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                SettingsView(container: container)
            }
        }
        .tint(DS.Color.accent)
    }

    private func openRehber() {
        quranSegment = .rehber
        selectedTab = 2
    }
}
