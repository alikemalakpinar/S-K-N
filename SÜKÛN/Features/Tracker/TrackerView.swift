import SwiftUI
import SwiftData
import Charts

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TrackerViewModel
    @State private var appeared = false

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: TrackerViewModel(container: container))
    }

    // Derived data
    private var totalDhikr: Int {
        viewModel.recentSessions.reduce(0) { $0 + $1.count }
    }
    private var totalReadingMinutes: Int {
        viewModel.recentReadingLogs.reduce(0) { $0 + $1.durationSeconds } / 60
    }
    private var activeDays: Int {
        let cal = Calendar.current
        var daySet = Set<DateComponents>()
        for log in viewModel.recentReadingLogs {
            daySet.insert(cal.dateComponents([.year, .month, .day], from: log.date))
        }
        for session in viewModel.recentSessions {
            daySet.insert(cal.dateComponents([.year, .month, .day], from: session.date))
        }
        return daySet.count
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Space.xl) {
                    // Triple activity rings hero
                    tripleRingsHero
                        .dsAppear(loaded: appeared, index: 0)

                    // Weekly dhikr chart
                    weeklyDhikrChart
                        .dsAppear(loaded: appeared, index: 1)

                    // Reading logs
                    readingSection
                        .dsAppear(loaded: appeared, index: 2)

                    // Dhikr sessions list
                    dhikrSection
                        .dsAppear(loaded: appeared, index: 3)
                }
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.md)
                .padding(.bottom, DS.Space.x4)
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Takip")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadRecentActivity(context: modelContext)
                withAnimation(DS.Motion.slowReveal) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Triple Activity Rings Hero

    private var tripleRingsHero: some View {
        HStack(spacing: DS.Space.xl) {
            // Rings
            ZStack {
                // Outer — Zikir (gold)
                ActivityRingTracker(
                    progress: min(1.0, Double(totalDhikr) / 500.0),
                    color: DS.Color.accent,
                    lineWidth: 10,
                    size: 130
                )
                // Middle — Okuma (green)
                ActivityRingTracker(
                    progress: min(1.0, Double(totalReadingMinutes) / 60.0),
                    color: DS.Color.success,
                    lineWidth: 10,
                    size: 96
                )
                // Inner — Aktif gün (cyan)
                ActivityRingTracker(
                    progress: min(1.0, Double(activeDays) / 7.0),
                    color: .cyan,
                    lineWidth: 10,
                    size: 62
                )
            }
            .frame(width: 140, height: 140)

            // Labels
            VStack(alignment: .leading, spacing: DS.Space.md) {
                ringLabel(
                    color: DS.Color.accent,
                    value: "\(totalDhikr)",
                    label: "Zikir",
                    target: "/ 500"
                )
                ringLabel(
                    color: DS.Color.success,
                    value: "\(totalReadingMinutes)",
                    label: "dk Okuma",
                    target: "/ 60"
                )
                ringLabel(
                    color: .cyan,
                    value: "\(activeDays)",
                    label: "Aktif Gün",
                    target: "/ 7"
                )
            }
        }
        .padding(DS.Space.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        )
    }

    private func ringLabel(color: Color, value: String, label: String, target: String) -> some View {
        HStack(spacing: DS.Space.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3, height: 24)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(DS.Color.textPrimary)
                    Text(target)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(DS.Color.textTertiary)
                }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
    }

    // MARK: - Weekly Dhikr Chart

    private var weeklyDhikrChart: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text("HAFTALIK ZİKİR")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(2)

            let dailyData = weeklyDhikrData()

            if dailyData.allSatisfy({ $0.count == 0 }) {
                emptyState("Henüz bu hafta zikir kaydı yok", icon: "chart.bar")
            } else {
                Chart {
                    ForEach(dailyData, id: \.day) { item in
                        BarMark(
                            x: .value("Gün", item.dayLabel),
                            y: .value("Sayı", item.count)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DS.Color.accent.opacity(0.6), DS.Color.accent],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(4)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(DS.Color.hairline)
                        AxisValueLabel()
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
                .frame(height: 160)
                .padding(.top, DS.Space.sm)
            }
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
    }

    private struct DayCount: Identifiable {
        let day: Date
        let dayLabel: String
        let count: Int
        var id: Date { day }
    }

    private func weeklyDhikrData() -> [DayCount] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let dayLabels = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]

        return (0..<7).map { offset in
            let day = cal.date(byAdding: .day, value: -(6 - offset), to: today) ?? today
            let nextDay = cal.date(byAdding: .day, value: 1, to: day) ?? today
            let count = viewModel.recentSessions
                .filter { $0.date >= day && $0.date < nextDay }
                .reduce(0) { $0 + $1.count }
            let weekday = cal.component(.weekday, from: day)
            // Convert Sunday=1..Saturday=7 to our Turkish labels
            let idx = (weekday + 5) % 7  // Mon=0, Tue=1, ..., Sun=6
            return DayCount(day: day, dayLabel: dayLabels[idx], count: count)
        }
    }

    // MARK: - Reading Section

    private var readingSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack {
                Text("OKUMA")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(2)
                Spacer()
                if !viewModel.recentReadingLogs.isEmpty {
                    Text("\(viewModel.recentReadingLogs.count) kayıt")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(DS.Color.textTertiary)
                }
            }

            if viewModel.recentReadingLogs.isEmpty {
                emptyState("Henüz okuma kaydı yok", icon: "book.closed")
            } else {
                ForEach(viewModel.recentReadingLogs, id: \.date) { log in
                    HStack(spacing: DS.Space.md) {
                        // Accent bar
                        RoundedRectangle(cornerRadius: 2)
                            .fill(DS.Color.success)
                            .frame(width: 3, height: 36)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Sure \(log.surahId): \(log.fromVerse)–\(log.toVerse)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(DS.Color.textPrimary)
                            Text(log.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                                .font(.system(size: 11))
                                .foregroundStyle(DS.Color.textSecondary)
                        }

                        Spacer()

                        Text("\(log.durationSeconds / 60) dk")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(DS.Color.success)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(DS.Color.success.opacity(0.1))
                            )
                    }
                    .padding(.vertical, DS.Space.xs)
                }
            }
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
    }

    // MARK: - Dhikr Section

    private var dhikrSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack {
                Text("ZİKİR SEANSLARI")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(2)
                Spacer()
                if !viewModel.recentSessions.isEmpty {
                    Text("\(viewModel.recentSessions.count) seans")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(DS.Color.textTertiary)
                }
            }

            if viewModel.recentSessions.isEmpty {
                emptyState("Henüz zikir seansı yok", icon: "circle.dashed")
            } else {
                ForEach(viewModel.recentSessions, id: \.date) { session in
                    HStack(spacing: DS.Space.md) {
                        // Count badge
                        Text("\(session.count)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(DS.Color.accent)
                            .frame(width: 56, alignment: .center)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                                    .fill(DS.Color.accentSoft)
                            )

                        VStack(alignment: .leading, spacing: 3) {
                            Text(session.presetTitle.isEmpty ? "Zikir" : session.presetTitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DS.Color.textPrimary)
                            Text(session.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                                .font(.system(size: 11))
                                .foregroundStyle(DS.Color.textSecondary)
                        }

                        Spacer()

                        if session.durationSeconds > 0 {
                            let mins = session.durationSeconds / 60
                            let secs = session.durationSeconds % 60
                            Text(mins > 0 ? "\(mins)dk \(secs)sn" : "\(secs)sn")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(DS.Color.textSecondary)
                        }
                    }
                    .padding(.vertical, DS.Space.xs)
                }
            }
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
    }

    private func emptyState(_ text: String, icon: String) -> some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(DS.Color.textTertiary)
            Text(text)
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                .fill(DS.Color.backgroundPrimary)
        )
    }
}

// MARK: - Reusable Activity Ring for Tracker

private struct ActivityRingTracker: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 10
    var size: CGFloat = 120

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(color.opacity(0.12), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color.opacity(0.5), color]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * max(animatedProgress, 0.01))
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Glowing end cap
            if animatedProgress > 0.05 {
                Circle()
                    .fill(color)
                    .frame(width: lineWidth, height: lineWidth)
                    .shadow(color: color.opacity(0.6), radius: 4)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * animatedProgress - 90))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.75).delay(0.3)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newVal in
            withAnimation(DS.Motion.standard) {
                animatedProgress = newVal
            }
        }
    }
}
