import SwiftUI
import SwiftData

struct JourneyView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: JourneyViewModel
    @State private var appeared = false
    @State private var countersAnimated = false
    @State private var weekDotsAnimated = false
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        _viewModel = State(initialValue: JourneyViewModel(container: container))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DS.Space.xl) {
                // Hero stats — animated counters
                heroStats
                    .dsAppear(loaded: appeared, index: 0)

                // Hatim progress
                hatimProgressCard
                    .dsAppear(loaded: appeared, index: 1)

                // Weekly activity dots
                weeklyActivitySection
                    .dsAppear(loaded: appeared, index: 2)

                // Milestones
                milestonesSection
                    .dsAppear(loaded: appeared, index: 3)
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.top, DS.Space.md)
            .padding(.bottom, DS.Space.x4 + 80)
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle(L10n.Journey.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.loadStats(context: modelContext)
            withAnimation(DS.Motion.slowReveal) { appeared = true }
            // Delayed counter animation
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                countersAnimated = true
            }
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                weekDotsAnimated = true
            }
        }
    }

    // MARK: - Hero Stats (Animated Counters)

    private var heroStats: some View {
        VStack(spacing: DS.Space.x2) {
            // Main counter — total pages
            VStack(spacing: DS.Space.xs) {
                Text(L10n.Journey.pagesReadTitle)
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(2)

                Text("\(countersAnimated ? viewModel.totalPagesRead : 0)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(DS.Color.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 1.2, dampingFraction: 0.7), value: countersAnimated)

                Text(L10n.Journey.ofTotal(604))
                    .font(DS.Typography.footnote)
                    .foregroundStyle(DS.Color.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.x2)

            // Three metric pills
            HStack(spacing: DS.Space.md) {
                metricPill(
                    icon: "flame.fill",
                    iconColor: DS.Color.warning,
                    value: countersAnimated ? viewModel.readingStreak : 0,
                    label: L10n.Journey.streak,
                    unit: L10n.Profile.days
                )

                metricPill(
                    icon: "circle.circle.fill",
                    iconColor: DS.Color.accent,
                    value: countersAnimated ? viewModel.totalDhikrCount : 0,
                    label: L10n.Journey.dhikrTotal,
                    unit: nil
                )

                metricPill(
                    icon: "checkmark.circle.fill",
                    iconColor: DS.Color.success,
                    value: countersAnimated ? viewModel.totalPrayersLogged : 0,
                    label: L10n.Journey.prayersWeek,
                    unit: nil
                )
            }
        }
        .padding(DS.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        )
    }

    private func metricPill(icon: String, iconColor: Color, value: Int, label: String, unit: String?) -> some View {
        VStack(spacing: DS.Space.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                        .fill(iconColor.opacity(0.1))
                )

            HStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Color.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: countersAnimated)
                    .monospacedDigit()

                if let unit {
                    Text(unit)
                        .font(DS.Typography.micro)
                        .foregroundStyle(DS.Color.textTertiary)
                }
            }

            Text(label)
                .font(DS.Typography.micro)
                .foregroundStyle(DS.Color.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Hatim Progress Card

    private var hatimProgressCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.Color.accent)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                            .fill(DS.Color.accentSoft)
                    )

                Text(L10n.Journey.hatimJourney)
                    .font(DS.Typography.listTitle)
                    .foregroundStyle(DS.Color.textPrimary)

                Spacer()

                Text("\(Int(viewModel.hatimProgress * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Color.accent)
                    .contentTransition(.numericText())
                    .monospacedDigit()
            }

            // Wide circular progress
            HStack(spacing: DS.Space.xl) {
                DSCircularProgress(
                    viewModel.hatimProgress,
                    size: 80,
                    lineWidth: 7,
                    color: DS.Color.accent,
                    showLabel: true
                )

                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    hatimDetail(label: L10n.Journey.pagesComplete, value: "\(viewModel.totalPagesRead)")
                    hatimDetail(label: L10n.Journey.pagesRemaining, value: "\(604 - viewModel.totalPagesRead)")
                    hatimDetail(label: L10n.Journey.juzComplete, value: "\(viewModel.totalPagesRead / 20)")
                }
            }
        }
        .padding(DS.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        )
    }

    private func hatimDetail(label: String, value: String) -> some View {
        HStack(spacing: DS.Space.sm) {
            Text(label)
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Color.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(DS.Color.textPrimary)
        }
    }

    // MARK: - Weekly Activity Dots (Wave Animation)

    private var weeklyActivitySection: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            Text(L10n.Journey.weeklyActivity)
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(2)

            HStack(spacing: 0) {
                ForEach(Array(viewModel.weeklyActivity.enumerated()), id: \.element.id) { index, day in
                    weekDayColumn(day, index: index)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, DS.Space.md)

            // Legend
            HStack(spacing: DS.Space.lg) {
                legendDot(color: DS.Color.success, label: L10n.Journey.legendPrayer)
                legendDot(color: DS.Color.accent, label: L10n.Journey.legendReading)
                legendDot(color: .cyan, label: L10n.Journey.legendDhikr)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(DS.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        )
    }

    private func weekDayColumn(_ day: JourneyViewModel.DayActivity, index: Int) -> some View {
        let delay = Double(index) * 0.08

        return VStack(spacing: DS.Space.sm) {
            // Activity dots (stacked)
            VStack(spacing: 3) {
                activityDot(active: day.hasPrayer, color: DS.Color.success, delay: delay)
                activityDot(active: day.hasReading, color: DS.Color.accent, delay: delay + 0.03)
                activityDot(active: day.hasDhikr, color: .cyan, delay: delay + 0.06)
            }

            Text(day.dayLabel)
                .font(DS.Typography.micro)
                .foregroundStyle(DS.Color.textSecondary)
        }
    }

    private func activityDot(active: Bool, color: Color, delay: Double) -> some View {
        Circle()
            .fill(active ? color : DS.Color.hairline)
            .frame(width: 10, height: 10)
            .scaleEffect(weekDotsAnimated ? 1.0 : 0.3)
            .opacity(weekDotsAnimated ? 1.0 : 0.3)
            .animation(
                .spring(response: 0.4, dampingFraction: 0.5).delay(delay),
                value: weekDotsAnimated
            )
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(DS.Typography.micro)
                .foregroundStyle(DS.Color.textSecondary)
        }
    }

    // MARK: - Milestones

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            Text(L10n.Journey.milestones)
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(2)

            VStack(spacing: DS.Space.md) {
                ForEach(Array(viewModel.milestones.enumerated()), id: \.element.id) { index, milestone in
                    milestoneRow(milestone, index: index)
                }
            }
        }
        .padding(DS.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        )
    }

    private func milestoneRow(_ milestone: JourneyViewModel.Milestone, index: Int) -> some View {
        let color = milestoneColor(milestone.color)

        return HStack(spacing: DS.Space.md) {
            // Icon badge
            ZStack {
                Circle()
                    .fill(milestone.isAchieved ? color.opacity(0.15) : DS.Color.hairline)
                    .frame(width: 40, height: 40)

                Image(systemName: milestone.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(milestone.isAchieved ? color : DS.Color.textTertiary)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(milestone.isAchieved ? DS.Color.textPrimary : DS.Color.textSecondary)

                Text(milestone.subtitle)
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textTertiary)
            }

            Spacer()

            // Checkmark
            if milestone.isAchieved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Circle()
                    .stroke(DS.Color.hairline, lineWidth: 1.5)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.vertical, DS.Space.xs)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.08 + 0.3),
            value: appeared
        )
    }

    private func milestoneColor(_ name: String) -> Color {
        switch name {
        case "success": DS.Color.success
        case "warning": DS.Color.warning
        default: DS.Color.accent
        }
    }
}

// MARK: - Preview

#Preview("Journey") {
    NavigationStack {
        DSPreview { c in JourneyView(container: c) }
    }
}
