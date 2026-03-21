import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SKNTabBar — Custom Floating Tab Bar
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  A floating capsule tab bar with matched-geometry sliding
//  indicator, bouncy spring transitions, and automatic hiding
//  in immersive modes (e.g., Mushaf reader, Dhikr session).
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MARK: - Tab Bar Visibility Environment Key

struct TabBarVisibleKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(true)
}

extension EnvironmentValues {
    var tabBarVisible: Binding<Bool> {
        get { self[TabBarVisibleKey.self] }
        set { self[TabBarVisibleKey.self] = newValue }
    }
}

// MARK: - Tab Definition

struct SKNTab: Identifiable, Hashable {
    let id: Int
    let icon: String
    let label: String
}

// MARK: - SKNTabBar

struct SKNTabBar: View {
    let tabs: [SKNTab]
    @Binding var selectedTab: Int
    @Binding var isVisible: Bool
    @Namespace private var tabNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, DS.Space.sm)
        .padding(.vertical, DS.Space.sm)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [DS.Color.glassBorder.opacity(0.8), DS.Color.glassBorder.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: DS.Color.accent.opacity(0.12), radius: 24, y: 12)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
        .padding(.horizontal, DS.Space.x2)
        .padding(.bottom, DS.Space.sm)
        .offset(y: isVisible ? 0 : 100)
        .opacity(isVisible ? 1 : 0)
        .animation(DS.Motion.standard, value: isVisible)
    }

    private func tabButton(_ tab: SKNTab) -> some View {
        let isSelected = selectedTab == tab.id

        return Button {
            guard selectedTab != tab.id else { return }
            DS.Haptic.selection()
            withAnimation(DS.Motion.tabSwitch) {
                selectedTab = tab.id
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: isSelected ? 18 : 17, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? DS.Color.accent : DS.Color.textTertiary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(DS.Motion.bouncy, value: isSelected)

                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? DS.Color.accent : DS.Color.textTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.sm)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [DS.Color.accentSoft, DS.Color.accentSoft.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: DS.Color.accent.opacity(0.2), radius: 8, y: 4)
                        .matchedGeometryEffect(id: "activeTab", in: tabNamespace)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview("SKNTabBar") {
    struct TabBarPreview: View {
        @State private var selectedTab = 0
        @State private var visible = true

        let tabs: [SKNTab] = [
            SKNTab(id: 0, icon: "house.fill", label: "Ana"),
            SKNTab(id: 1, icon: "clock.fill", label: "Vakit"),
            SKNTab(id: 2, icon: "book.fill", label: "Kuran"),
            SKNTab(id: 3, icon: "location.north.fill", label: "Kıble"),
            SKNTab(id: 4, icon: "circle.circle.fill", label: "Zikir"),
            SKNTab(id: 5, icon: "chart.xyaxis.line", label: "Analiz"),
        ]

        var body: some View {
            ZStack(alignment: .bottom) {
                DS.Color.backgroundPrimary.ignoresSafeArea()

                VStack {
                    Text("Selected: \(selectedTab)")
                        .font(DS.Typography.headline)
                    Button("Toggle Visibility") {
                        visible.toggle()
                    }
                }

                SKNTabBar(tabs: tabs, selectedTab: $selectedTab, isVisible: $visible)
            }
        }
    }

    return TabBarPreview()
}
