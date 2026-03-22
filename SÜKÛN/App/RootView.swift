import SwiftUI

struct RootView: View {
    let container: DependencyContainer
    @State private var selectedTab = 0
    @State private var tabBarVisible = true
    @State private var quranSegment: QuranSegment = .mushaf
    @State private var resumePage: Int?
    @State private var showRehber = false

    private let tabs: [SKNTab] = [
        SKNTab(id: 0, icon: "house.fill", label: "Ana Ekran"),
        SKNTab(id: 1, icon: "clock.fill", label: "Vakitler"),
        SKNTab(id: 2, icon: "book.fill", label: "Kuran"),
        SKNTab(id: 3, icon: "location.north.fill", label: "Kıble"),
        SKNTab(id: 4, icon: "circle.circle.fill", label: "Zikir"),
        SKNTab(id: 5, icon: "chart.xyaxis.line", label: "Analiz")
    ]

    var body: some View {
        ZStack {
            // Tab content — all views stay alive to preserve NavigationStack state
            Group {
                switch selectedTab {
                case 0:
                    DashboardView(container: container, onOpenRehber: openRehber, onResumeReading: resumeReading)
                case 1:
                    PrayerTimesView(container: container)
                case 2:
                    QuranView(container: container, selectedSegment: $quranSegment, resumePage: $resumePage, showRehber: $showRehber)
                case 3:
                    QiblaSceneKitView()
                case 4:
                    TasbihSpriteView()
                case 5:
                    SpiritualJourneyView()
                default:
                    DashboardView(container: container, onOpenRehber: openRehber, onResumeReading: resumeReading)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            SKNTabBar(tabs: tabs, selectedTab: $selectedTab, isVisible: $tabBarVisible)
        }
        .ignoresSafeArea(.keyboard)
        .environment(\.tabBarVisible, $tabBarVisible)
    }

    private func openRehber() {
        selectedTab = 2
        showRehber = true
    }

    private func resumeReading(_ page: Int) {
        resumePage = page
        quranSegment = .mushaf
        selectedTab = 2
    }
}
