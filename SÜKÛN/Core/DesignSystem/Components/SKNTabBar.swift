import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SKNTabBar — Premium Floating Tab Bar
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  A floating capsule tab bar with:
//  - Matched-geometry sliding indicator with accent glow
//  - Bouncy spring transitions and haptic feedback
//  - Badge support for notification dots
//  - Auto-hide in immersive modes
//  - AlongSanss2 typography
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
    var badge: Int = 0
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
                                colors: [
                                    DS.Color.glassBorder.opacity(0.8),
                                    DS.Color.glassBorder.opacity(0.05),
                                    DS.Color.glassBorder.opacity(0.3),
                                    DS.Color.glassBorder.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                // Multi-layered premium shadow
                .shadow(color: DS.Color.accent.opacity(0.08), radius: 30, y: 15)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
                .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
        }
        .padding(.horizontal, DS.Space.xl)
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
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 18 : 17, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? DS.Color.accent : DS.Color.textTertiary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(DS.Motion.bouncy, value: isSelected)
                        .symbolEffect(.bounce.byLayer, value: isSelected)

                    // Badge dot
                    if tab.badge > 0 {
                        Circle()
                            .fill(DS.Color.accent)
                            .frame(width: 6, height: 6)
                            .offset(x: 3, y: -2)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                Text(tab.label)
                    .font(DS.Typography.alongSans(size: 10, weight: isSelected ? "SemiBold" : "Regular"))
                    .foregroundStyle(isSelected ? DS.Color.accent : DS.Color.textTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.sm)
            .background {
                if isSelected {
                    ZStack {
                        // Soft glow behind active tab
                        Capsule(style: .continuous)
                            .fill(DS.Color.accent.opacity(0.06))
                            .blur(radius: 12)

                        // Active indicator pill
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [DS.Color.accentSoft, DS.Color.accentSoft.opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: DS.Color.accent.opacity(0.2), radius: 10, y: 4)
                    }
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
            SKNTab(id: 3, icon: "location.north.fill", label: "Kible"),
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
