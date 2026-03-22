import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ProfileViewModel
    @State private var appeared = false
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        _viewModel = State(initialValue: ProfileViewModel(container: container))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                avatarHeader
                    .dsAppear(loaded: appeared, index: 0)

                hatimCard
                    .padding(.top, DS.Space.xl)
                    .dsAppear(loaded: appeared, index: 1)

                statsGrid
                    .padding(.top, DS.Space.lg)
                    .dsAppear(loaded: appeared, index: 2)

                todayPrayersCard
                    .padding(.top, DS.Space.lg)
                    .dsAppear(loaded: appeared, index: 3)

                quickLinksSection
                    .dsAppear(loaded: appeared, index: 4)
            }
            .padding(.bottom, DS.Space.x4)
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle(L10n.Profile.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.loadStats(context: modelContext)
            withAnimation(DS.Motion.slowReveal) { appeared = true }
        }
    }

    // MARK: - Avatar Header

    private var avatarHeader: some View {
        VStack(spacing: DS.Space.lg) {
            ZStack {
                // Outer decorative rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(
                            DS.Color.accent.opacity(0.08 - Double(i) * 0.02),
                            lineWidth: 0.5
                        )
                        .frame(
                            width: CGFloat(96 + i * 16),
                            height: CGFloat(96 + i * 16)
                        )
                }

                // Ambient glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DS.Color.accent.opacity(0.12),
                                DS.Color.accent.opacity(0.04),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 55
                        )
                    )
                    .frame(width: 100, height: 100)

                // Avatar circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DS.Color.accent.opacity(0.18),
                                DS.Color.accent.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .stroke(DS.Color.accent.opacity(0.2), lineWidth: 1)
                    )

                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DS.Color.accent, DS.Color.accent.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: DS.Space.sm) {
                Text(L10n.Profile.myJourney)
                    .font(DS.Typography.displayBody)
                    .foregroundStyle(DS.Color.textPrimary)

                if viewModel.readingStreak > 0 {
                    HStack(spacing: DS.Space.xs) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(DS.Color.warning)
                            .shadow(color: DS.Color.warning.opacity(0.4), radius: 4)
                        Text("\(viewModel.readingStreak) \(L10n.Profile.days)")
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                    .padding(.horizontal, DS.Space.md)
                    .padding(.vertical, DS.Space.xs)
                    .background(
                        Capsule()
                            .fill(DS.Color.warning.opacity(0.08))
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.x2)
    }

    // MARK: - Hatim Progress Card

    private var hatimCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                HStack {
                    Image(systemName: "book.fill")
                        .font(DS.Typography.alongSans(size: 14, weight: "Medium"))
                        .foregroundStyle(DS.Color.accent)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                                .fill(DS.Color.accentSoft)
                        )

                    Text(L10n.Profile.hatimProgress)
                        .font(DS.Typography.listTitle)
                        .foregroundStyle(DS.Color.textPrimary)

                    Spacer()

                    Text("\(Int(viewModel.hatimProgress * 100))%")
                        .font(DS.Typography.caption)
                        .foregroundStyle(DS.Color.accent)
                        .monospacedDigit()
                }

                DSProgressBar(viewModel.hatimProgress, height: 8)

                Text("\(viewModel.totalPagesRead) / 604 \(L10n.Profile.pagesRead.lowercased())")
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textTertiary)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, DS.Space.lg)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: DS.Space.md) {
            statCard(
                icon: "flame.fill",
                iconColor: DS.Color.warning,
                value: viewModel.readingStreak > 0 ? "\(viewModel.readingStreak)" : "-",
                label: L10n.Profile.readingStreak,
                unit: viewModel.readingStreak > 0 ? L10n.Profile.days : nil
            )

            statCard(
                icon: "doc.text.fill",
                iconColor: DS.Color.success,
                value: "\(viewModel.totalPagesRead)",
                label: L10n.Profile.pagesRead,
                unit: nil
            )

            statCard(
                icon: "circle.circle.fill",
                iconColor: DS.Color.accent,
                value: formattedDhikr,
                label: L10n.Profile.totalDhikr,
                unit: nil
            )
        }
        .padding(.horizontal, DS.Space.lg)
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String, unit: String?) -> some View {
        VStack(spacing: DS.Space.sm) {
            Image(systemName: icon)
                .font(DS.Typography.listTitle)
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                        .fill(iconColor.opacity(0.1))
                )

            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Text(value)
                        .font(DS.Typography.headline)
                        .foregroundStyle(DS.Color.textPrimary)
                        .monospacedDigit()

                    if let unit {
                        Text(unit)
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.textTertiary)
                    }
                }

                Text(label)
                    .font(DS.Typography.micro)
                    .foregroundStyle(DS.Color.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(DS.Color.cardElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(DS.Color.hairline, lineWidth: 0.5)
        )
        .dsShadow(DS.Shadow.card)
    }

    // MARK: - Today's Prayers

    private var todayPrayersCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                HStack {
                    Text(L10n.Profile.todayPrayers)
                        .font(DS.Typography.listTitle)
                        .foregroundStyle(DS.Color.textPrimary)

                    Spacer()

                    Text("\(viewModel.todayPrayerCount)/5")
                        .font(DS.Typography.caption)
                        .foregroundStyle(DS.Color.accent)
                        .monospacedDigit()
                }

                if let log = viewModel.todayPrayerLog {
                    HStack(spacing: DS.Space.md) {
                        prayerPill(L10n.Prayer.fajr, status: log.fajr)
                        prayerPill(L10n.Prayer.dhuhr, status: log.dhuhr)
                        prayerPill(L10n.Prayer.asr, status: log.asr)
                        prayerPill(L10n.Prayer.maghrib, status: log.maghrib)
                        prayerPill(L10n.Prayer.isha, status: log.isha)
                    }
                } else {
                    HStack(spacing: DS.Space.md) {
                        ForEach([L10n.Prayer.fajr, L10n.Prayer.dhuhr, L10n.Prayer.asr, L10n.Prayer.maghrib, L10n.Prayer.isha], id: \.self) { name in
                            prayerPill(name, status: .notLogged)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, DS.Space.lg)
    }

    private func prayerPill(_ name: String, status: PrayerStatus) -> some View {
        VStack(spacing: DS.Space.xs) {
            ZStack {
                Circle()
                    .fill(pillColor(status).opacity(0.12))
                    .frame(width: 32, height: 32)

                Image(systemName: pillIcon(status))
                    .font(DS.Typography.alongSans(size: 12, weight: "Medium"))
                    .foregroundStyle(pillColor(status))
            }

            Text(String(name.prefix(3)))
                .font(DS.Typography.micro)
                .foregroundStyle(DS.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func pillColor(_ status: PrayerStatus) -> Color {
        switch status {
        case .prayed: DS.Color.success
        case .missed: Color(hex: 0xE05C4D)
        case .late: DS.Color.warning
        case .notLogged: DS.Color.textTertiary.opacity(0.5)
        }
    }

    private func pillIcon(_ status: PrayerStatus) -> String {
        switch status {
        case .prayed: "checkmark"
        case .missed: "xmark"
        case .late: "clock"
        case .notLogged: "minus"
        }
    }

    // MARK: - Quick Links

    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSSectionHeader(L10n.Profile.quickLinks, serif: true)

            DSCard {
                VStack(spacing: 0) {
                    NavigationLink {
                        JourneyView(container: container)
                    } label: {
                        quickLinkRow(
                            icon: "map.fill",
                            iconColor: DS.Color.accent,
                            title: L10n.Journey.title
                        )
                    }
                    .buttonStyle(.plain)

                    Hairline()

                    NavigationLink {
                        TrackerView(container: container)
                    } label: {
                        quickLinkRow(
                            icon: "chart.bar.fill",
                            iconColor: DS.Color.success,
                            title: L10n.Profile.tracker
                        )
                    }
                    .buttonStyle(.plain)

                    Hairline()

                    NavigationLink {
                        BookmarksView(container: container)
                    } label: {
                        quickLinkRow(
                            icon: "bookmark.fill",
                            iconColor: DS.Color.accent,
                            title: L10n.Profile.bookmarks
                        )
                    }
                    .buttonStyle(.plain)

                    Hairline()

                    NavigationLink {
                        SettingsView(container: container)
                    } label: {
                        quickLinkRow(
                            icon: "gearshape.fill",
                            iconColor: DS.Color.textSecondary,
                            title: L10n.Profile.settings
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DS.Space.lg)
        }
    }

    private func quickLinkRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: icon)
                .font(DS.Typography.alongSans(size: 14, weight: "Medium"))
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.sm + 2, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                )

            Text(title)
                .font(DS.Typography.listTitle)
                .foregroundStyle(DS.Color.textPrimary)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textTertiary)
        }
        .padding(.vertical, DS.Space.sm)
        .contentShape(Rectangle())
    }

    // MARK: - Helpers

    private var formattedDhikr: String {
        if viewModel.totalDhikrCount >= 1000 {
            return String(format: "%.1fK", Double(viewModel.totalDhikrCount) / 1000.0)
        }
        return "\(viewModel.totalDhikrCount)"
    }
}

// MARK: - Preview

#Preview("Profile") {
    NavigationStack {
        DSPreview { c in ProfileView(container: c) }
    }
}
