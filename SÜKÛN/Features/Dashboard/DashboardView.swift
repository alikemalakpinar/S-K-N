import SwiftUI
import SwiftData
import CoreLocation

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel
    var onOpenRehber: (() -> Void)?
    var onResumeReading: ((Int) -> Void)?
    private let container: DependencyContainer

    init(container: DependencyContainer, onOpenRehber: (() -> Void)? = nil, onResumeReading: ((Int) -> Void)? = nil) {
        self.container = container
        _viewModel = State(initialValue: DashboardViewModel(container: container))
        self.onOpenRehber = onOpenRehber
        self.onResumeReading = onResumeReading
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Giant countdown — THE hero
                    countdownHero
                        .padding(.top, DS.Space.x3)

                    // Prayer checklist
                    prayerChecklist
                        .padding(.top, DS.Space.x3)
                        .padding(.horizontal, DS.Space.lg)

                    // Last read position
                    if viewModel.lastReadPosition != nil {
                        lastReadCard
                            .padding(.top, DS.Space.xl)
                            .padding(.horizontal, DS.Space.lg)
                            .staggerIn(index: 0, loaded: viewModel.isDashboardLoaded)
                    }

                    // Verse of the day
                    if viewModel.verseOfTheDay != nil {
                        verseOfTheDayCard
                            .padding(.top, DS.Space.xl)
                            .padding(.horizontal, DS.Space.lg)
                            .staggerIn(index: 1, loaded: viewModel.isDashboardLoaded)
                    }

                    // Quran progress
                    if viewModel.totalUniquePages > 0 || viewModel.readingStreakDays > 0 {
                        progressSection
                            .padding(.top, DS.Space.xl)
                            .padding(.horizontal, DS.Space.lg)
                            .staggerIn(index: 2, loaded: viewModel.isDashboardLoaded)
                    }

                    // Quick action
                    rehberCard
                        .padding(.top, DS.Space.xl)
                        .padding(.horizontal, DS.Space.lg)
                        .staggerIn(index: 3, loaded: viewModel.isDashboardLoaded)

                    Spacer(minLength: DS.Space.x4)
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Sükûn")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadTodayData(context: modelContext)

                let descriptor = FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" })
                let settings = (try? modelContext.fetch(descriptor))?.first
                let method = settings?.calculationMethod ?? "Turkey"
                let asr = settings?.asrMethod ?? "hanafi"

                // Try cached prayer times first (no location needed)
                if let cached = await container.prayerTimeService.loadCached(),
                   let today = cached.first {
                    if let next = container.prayerTimeService.nextPrayer(from: today, after: Date()) {
                        viewModel.nextPrayerName = next.name
                        viewModel.nextPrayerTime = next.time
                    }
                }

                // Then try fresh location in background (non-blocking)
                do {
                    let coords = try await container.locationService.currentCoordinates()
                    await viewModel.loadNextPrayer(
                        latitude: coords.latitude,
                        longitude: coords.longitude,
                        method: method,
                        asrMethod: asr
                    )
                } catch {
                    // Location unavailable — keep cached data or placeholder
                }
            }
        }
    }

    // MARK: - Countdown Hero

    private var countdownHero: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let now = timeline.date

            VStack(spacing: 0) {
                // Prayer name
                Text(viewModel.nextPrayerName.uppercased())
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(4)

                if let time = viewModel.nextPrayerTime {
                    let remaining = max(0, time.timeIntervalSince(now))
                    let hours = Int(remaining) / 3600
                    let minutes = (Int(remaining) % 3600) / 60
                    let seconds = Int(remaining) % 60

                    // Hours — ghost large
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(String(format: "%02d", hours))
                            .font(.system(size: 120, weight: .black))
                            .foregroundStyle(DS.Color.textTertiary)
                        Text("sa")
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                            .padding(.leading, DS.Space.xs)
                    }
                    .padding(.top, -DS.Space.sm)

                    // Minutes — bold, prominent
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(String(format: "%02d", minutes))
                            .font(.system(size: 120, weight: .black))
                            .foregroundStyle(DS.Color.textPrimary.opacity(0.6))
                        Text("dk")
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                            .padding(.leading, DS.Space.xs)
                    }
                    .padding(.top, -DS.Space.x3)

                    // Seconds — darkest, biggest impact
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(String(format: "%02d", seconds))
                            .font(.system(size: 120, weight: .black))
                            .foregroundStyle(DS.Color.textPrimary)
                        Text("sn")
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                            .padding(.leading, DS.Space.xs)
                    }
                    .padding(.top, -DS.Space.x3)

                    // Actual prayer time
                    Text(time, format: .dateTime.hour().minute())
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(DS.Color.accent)
                        .padding(.top, DS.Space.md)

                } else {
                    // No data placeholder — still beautiful
                    Text("00")
                        .font(.system(size: 120, weight: .black))
                        .foregroundStyle(DS.Color.textTertiary)
                    Text("00")
                        .font(.system(size: 120, weight: .black))
                        .foregroundStyle(DS.Color.textTertiary)
                        .padding(.top, -DS.Space.x3)
                }
            }
            .frame(maxWidth: .infinity)
            .contentTransition(.numericText())
            .animation(.easeOut(duration: 0.2), value: Int(viewModel.nextPrayerTime?.timeIntervalSince(now) ?? 0))
        }
    }

    // MARK: - Prayer Checklist

    private var prayerChecklist: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            Text("GÜNÜN NAMAZLARI")
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(3)

            if let log = viewModel.todayLog {
                HStack(spacing: 0) {
                    PrayerPill(name: "Sabah", status: log.fajr)
                    Spacer()
                    PrayerPill(name: "Öğle", status: log.dhuhr)
                    Spacer()
                    PrayerPill(name: "İkindi", status: log.asr)
                    Spacer()
                    PrayerPill(name: "Akşam", status: log.maghrib)
                    Spacer()
                    PrayerPill(name: "Yatsı", status: log.isha)
                }
            } else {
                HStack(spacing: 0) {
                    PrayerPill(name: "Sabah", status: .notLogged)
                    Spacer()
                    PrayerPill(name: "Öğle", status: .notLogged)
                    Spacer()
                    PrayerPill(name: "İkindi", status: .notLogged)
                    Spacer()
                    PrayerPill(name: "Akşam", status: .notLogged)
                    Spacer()
                    PrayerPill(name: "Yatsı", status: .notLogged)
                }
            }
        }
    }

    // MARK: - Last Read Card

    @ViewBuilder
    private var lastReadCard: some View {
        if let position = viewModel.lastReadPosition {
            Button {
                onResumeReading?(position.mushafPage)
            } label: {
                HStack(spacing: DS.Space.md) {
                    ZStack {
                        Circle()
                            .fill(DS.Color.accentSoft)
                            .frame(width: 44, height: 44)
                        Image(systemName: "book.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(DS.Color.accent)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("KALDIĞIN YER")
                            .font(DS.Typography.sectionHead)
                            .foregroundStyle(DS.Color.textSecondary)
                            .tracking(2)
                        Text(position.surahNameTurkish)
                            .font(DS.Typography.headline)
                            .foregroundStyle(DS.Color.textPrimary)
                        Text("Sayfa \(position.mushafPage)")
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(DS.Color.accent)
                }
                .padding(DS.Space.lg)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DS.Color.cardElevated)
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Verse of the Day

    @ViewBuilder
    private var verseOfTheDayCard: some View {
        if let verse = viewModel.verseOfTheDay {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                // Header
                HStack {
                    Label {
                        Text("GÜNÜN AYETİ")
                            .font(DS.Typography.sectionHead)
                            .tracking(2)
                    } icon: {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(DS.Color.accent)

                    Spacer()

                    Text("\(verse.surahId):\(verse.verseNumber)")
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.textSecondary)
                }

                // Arabic text
                Text(verse.textArabic)
                    .font(DS.Typography.arabicLarge)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(12)
                    .foregroundStyle(DS.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                // Translation
                Text(verse.textTranslation)
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
                    .lineSpacing(4)

                // Surah name
                Text("— \(viewModel.verseOfTheDaySurahName)")
                    .font(DS.Typography.captionSm)
                    .italic()
                    .foregroundStyle(DS.Color.accent.opacity(0.7))
            }
            .padding(DS.Space.lg)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DS.Color.quranCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DS.Color.ornamentLine, lineWidth: 0.5)
            )
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        HStack(spacing: DS.Space.lg) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(DS.Color.hairline, lineWidth: 6)
                    .frame(width: 72, height: 72)
                Circle()
                    .trim(from: 0, to: min(1.0, viewModel.quranProgressPercent))
                    .stroke(DS.Color.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(Int(viewModel.quranProgressPercent * 100))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(DS.Color.textPrimary)
                    Text("%")
                        .font(DS.Typography.micro)
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: DS.Space.sm) {
                // Daily progress bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Bugün")
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.textSecondary)
                        Spacer()
                        Text("\(viewModel.pagesReadToday)/\(viewModel.dailyPageGoal) sayfa")
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.accent)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(DS.Color.hairline)
                                .frame(height: 5)
                            Capsule()
                                .fill(DS.Color.accent)
                                .frame(
                                    width: geo.size.width * min(1.0, Double(viewModel.pagesReadToday) / Double(max(1, viewModel.dailyPageGoal))),
                                    height: 5
                                )
                        }
                    }
                    .frame(height: 5)
                }

                // Streak
                HStack(spacing: DS.Space.xs) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.orange)
                    Text("\(viewModel.readingStreakDays) gün seri")
                        .font(DS.Typography.caption)
                        .foregroundStyle(DS.Color.textPrimary)
                }
            }
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }

    // MARK: - Rehber Card

    private var rehberCard: some View {
        Button {
            onOpenRehber?()
        } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: "book.pages")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(DS.Color.accent)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(DS.Color.accentSoft)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Bilgi Tazele")
                        .font(DS.Typography.headline)
                        .foregroundStyle(DS.Color.textPrimary)
                    Text("Temel esaslar ve hatırlatmalar")
                        .font(DS.Typography.captionSm)
                        .foregroundStyle(DS.Color.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .padding(DS.Space.lg)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DS.Color.cardElevated)
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Prayer Pill

private struct PrayerPill: View {
    let name: String
    let status: PrayerStatus

    private var isPrayed: Bool { status == .prayed }

    var body: some View {
        VStack(spacing: DS.Space.sm) {
            ZStack {
                Circle()
                    .fill(isPrayed ? DS.Color.accent : DS.Color.cardElevated)
                    .frame(width: 48, height: 48)
                    .shadow(color: .black.opacity(isPrayed ? 0.06 : 0.03), radius: 4, y: 1)

                if isPrayed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .stroke(DS.Color.hairline, lineWidth: 1.5)
                        .frame(width: 48, height: 48)
                }
            }

            Text(name)
                .font(DS.Typography.captionSm)
                .foregroundStyle(isPrayed ? DS.Color.accent : DS.Color.textSecondary)
        }
    }
}

// MARK: - Stagger Animation

private struct StaggerModifier: ViewModifier {
    let index: Int
    let loaded: Bool

    func body(content: Content) -> some View {
        content
            .opacity(loaded ? 1 : 0)
            .offset(y: loaded ? 0 : 16)
            .animation(
                DS.Motion.standard.delay(Double(index) * 0.1),
                value: loaded
            )
    }
}

extension View {
    fileprivate func staggerIn(index: Int, loaded: Bool) -> some View {
        modifier(StaggerModifier(index: index, loaded: loaded))
    }
}
