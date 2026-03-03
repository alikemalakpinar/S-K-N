import SwiftUI

struct RootView: View {
    let container: DependencyContainer
    @State private var selectedTab = 0
    @State private var quranSegment: QuranSegment = .mushaf

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Ana Sayfa", systemImage: "house.fill", value: 0) {
                DashboardView(container: container, onOpenRehber: openRehber)
            }

            Tab("Namaz", systemImage: "clock.fill", value: 1) {
                PrayerTimesView(container: container)
            }

            Tab("Kur'an", systemImage: "book.fill", value: 2) {
                QuranView(container: container, selectedSegment: $quranSegment)
            }

            Tab("Zikir", systemImage: "circle.circle.fill", value: 3) {
                DhikrView(container: container)
            }

            Tab("Ayarlar", systemImage: "gearshape.fill", value: 4) {
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
