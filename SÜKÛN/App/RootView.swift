import SwiftUI

struct RootView: View {
    let container: DependencyContainer
    @State private var selectedTab = 0
    @State private var quranSegment: QuranSegment = .mushaf
    @State private var resumePage: Int?

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Ana Sayfa", systemImage: "house.fill", value: 0) {
                DashboardView(container: container, onOpenRehber: openRehber, onResumeReading: resumeReading)
            }

            Tab("Namaz", systemImage: "clock.fill", value: 1) {
                PrayerTimesView(container: container)
            }

            Tab("Kur'an", systemImage: "book.fill", value: 2) {
                QuranView(container: container, selectedSegment: $quranSegment, resumePage: $resumePage)
            }

            Tab("Kıble", systemImage: "location.north.fill", value: 3) {
                QiblaView()
            }

            Tab("Zikir", systemImage: "circle.circle.fill", value: 4) {
                DhikrView(container: container)
            }
        }
        .tint(DS.Color.accent)
    }

    private func openRehber() {
        quranSegment = .rehber
        selectedTab = 2
    }

    private func resumeReading(_ page: Int) {
        resumePage = page
        quranSegment = .mushaf
        selectedTab = 2
    }
}
