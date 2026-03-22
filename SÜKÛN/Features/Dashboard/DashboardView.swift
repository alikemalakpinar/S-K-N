import SwiftUI
import SwiftData
import CoreLocation

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel
    @State private var scrollOffset: CGFloat = 0
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
                    // Scroll offset tracker
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: -geo.frame(in: .named("dashScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    // Greeting + location header — fades on scroll
                    greetingHeader
                        .padding(.top, DS.Space.lg)
                        .padding(.horizontal, DS.Space.lg)
                        .opacity(max(0, 1.0 - scrollOffset / 120))
                        .offset(y: min(0, -scrollOffset * 0.15))

                    // Giant typographic countdown — THE HERO — parallax compress
                    countdownHero
                        .padding(.top, DS.Space.md)
                        .scaleEffect(max(0.92, 1.0 - scrollOffset / 2000), anchor: .top)

                    // Prayer checklist
                    prayerChecklist
                        .padding(.top, DS.Space.x3)
                        .padding(.horizontal, DS.Space.lg)

                    // Horizontal widget strip
                    horizontalWidgets
                        .padding(.top, DS.Space.xl)
                        .dsAppear(loaded: viewModel.isDashboardLoaded, index: 0)

                    // Verse of the day
                    if viewModel.verseOfTheDay != nil {
                        verseOfTheDayCard
                            .padding(.top, DS.Space.xl)
                            .padding(.horizontal, DS.Space.lg)
                            .dsAppear(loaded: viewModel.isDashboardLoaded, index: 1)
                    }

                    // Quick actions grid
                    quickActionsGrid
                        .padding(.top, DS.Space.xl)
                        .padding(.horizontal, DS.Space.lg)
                        .dsAppear(loaded: viewModel.isDashboardLoaded, index: 2)

                    Spacer(minLength: DS.Space.x4 + 80)
                }
            }
            .coordinateSpace(name: "dashScroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = max(0, value)
            }
            // TITANIUM UPGRADE: Boids Flocking + Fluid Canvas Particles (120FPS)
            .background(FluidBackgroundView())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(L10n.Dashboard.title)
                            .font(DS.Typography.displayBody)
                            .foregroundStyle(DS.Color.textPrimary)
                        Text(Self.hijriDateString)
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: DS.Space.md) {
                        NavigationLink {
                            ProfileView(container: container)
                        } label: {
                            Image(systemName: "person.circle")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(DS.Color.accent)
                        }

                        NavigationLink {
                            SettingsView(container: container)
                        } label: {
                            Image(systemName: "gearshape")
                                .font(DS.Typography.listTitle)
                                .foregroundStyle(DS.Color.textSecondary)
                        }
                    }
                }
            }
            .task {
                await viewModel.loadTodayData(context: modelContext)

                let descriptor = FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" })
                let settings = (try? modelContext.fetch(descriptor))?.first
                let method = settings?.calculationMethod ?? "Turkey"
                let asr = settings?.asrMethod ?? "hanafi"

                if let cached = await container.prayerTimeService.loadCached(),
                   let today = cached.first {
                    if let next = container.prayerTimeService.nextPrayer(from: today, after: Date()) {
                        viewModel.nextPrayerName = next.name
                        viewModel.nextPrayerTime = next.time
                    }
                }

                do {
                    let coords = try await container.locationService.currentCoordinates()
                    viewModel.loadLocationName(latitude: coords.latitude, longitude: coords.longitude)
                    await viewModel.loadNextPrayer(
                        latitude: coords.latitude,
                        longitude: coords.longitude,
                        method: method,
                        asrMethod: asr
                    )

                    // Auto-start Live Activity if enabled in settings
                    if settings?.liveActivityEnabled == true,
                       !container.liveActivityManager.isLiveActivityActive {
                        viewModel.startLiveActivity()
                    } else if container.liveActivityManager.isLiveActivityActive {
                        viewModel.startPeriodicLiveActivityUpdates()
                    }
                } catch {}
            }
            .onDisappear {
                viewModel.stopPeriodicLiveActivityUpdates()
            }
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack(spacing: DS.Space.sm) {
                Image(systemName: viewModel.greetingIcon)
                    .font(DS.Typography.bodyMedium)
                    .foregroundStyle(DS.Color.accent)
                    .symbolEffect(.pulse, options: .repeating.speed(0.3))

                Text(viewModel.greeting)
                    .font(DS.Typography.alongSans(size: 14, weight: "Medium"))
                    .foregroundStyle(DS.Color.textSecondary)
            }

            Text(viewModel.locationName.isEmpty ? L10n.Dashboard.locationLoading : viewModel.locationName)
                .font(DS.Typography.displayTitle)
                .foregroundStyle(DS.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Countdown Hero (Typographic Clock)

    private let bandHeight: CGFloat = 120

    private var countdownHero: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let now = timeline.date

            VStack(spacing: 0) {
                if let time = viewModel.nextPrayerTime {
                    let remaining = max(0, time.timeIntervalSince(now))
                    let hours = Int(remaining) / 3600
                    let minutes = (Int(remaining) % 3600) / 60
                    let seconds = Int(remaining) % 60

                    countdownBand(
                        value: String(format: "%02d", hours),
                        label: L10n.Common.hour,
                        opacity: 0.08
                    )
                    countdownBand(
                        value: String(format: "%02d", minutes),
                        label: L10n.Common.minute,
                        opacity: 0.25
                    )
                    countdownBand(
                        value: String(format: "%02d", seconds),
                        label: L10n.Common.second,
                        opacity: 0.90
                    )

                    // Prayer info row
                    HStack(alignment: .firstTextBaseline) {
                        Text(viewModel.nextPrayerName.uppercased())
                            .font(DS.Typography.alongSans(size: 12, weight: "Bold"))
                            .foregroundStyle(DS.Color.textPrimary.opacity(0.4))
                            .tracking(4)

                        Spacer()

                        Text(time, format: .dateTime.hour().minute())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(DS.Color.textPrimary.opacity(0.35))
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.top, DS.Space.lg)

                } else {
                    countdownBand(value: "--", label: L10n.Common.hour, opacity: 0.08)
                    countdownBand(value: "--", label: L10n.Common.minute, opacity: 0.25)
                    countdownBand(value: "--", label: L10n.Common.second, opacity: 0.90)
                }
            }
            .frame(maxWidth: .infinity)
            .contentTransition(.numericText())
            .animation(.easeOut(duration: 0.15), value: Int(viewModel.nextPrayerTime?.timeIntervalSince(now) ?? 0))
        }
    }

    private func countdownBand(value: String, label: String, opacity: Double) -> some View {
        ZStack {
            Text(value)
                .font(.system(size: 260, weight: .bold).width(.compressed)) // Peak Apple UI width
                .foregroundStyle(.ultraThinMaterial) // Apple Vision Pro Glass Typography
                .blendMode(.overlay) // Melts into the fluid background
                .tracking(-12)
                .lineLimit(1)
                .fixedSize()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, DS.Space.sm)

            VStack {
                HStack {
                    Spacer()
                    Text(label)
                        .font(DS.Typography.chipLabel)
                        .foregroundStyle(DS.Color.textPrimary.opacity(max(0.15, opacity * 0.4)))
                        .tracking(2)
                        .padding(.top, DS.Space.sm)
                        .padding(.trailing, DS.Space.lg)
                }
                Spacer()
            }
        }
        .frame(height: bandHeight)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(DS.Color.textPrimary.opacity(0.06))
                .frame(height: 1)
        }
    }

    // MARK: - Prayer Checklist

    private var prayerChecklist: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            HStack {
                DSFormSectionHeader(L10n.Dashboard.todayPrayers)

                Spacer()

                Text("\(viewModel.prayedCount)/5")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Color.accent)
            }

            if let log = viewModel.todayLog {
                HStack(spacing: 0) {
                    PrayerPill(name: L10n.Prayer.fajr, status: log.fajr) { togglePrayer("fajr") }
                    Spacer()
                    PrayerPill(name: L10n.Prayer.dhuhr, status: log.dhuhr) { togglePrayer("dhuhr") }
                    Spacer()
                    PrayerPill(name: L10n.Prayer.asr, status: log.asr) { togglePrayer("asr") }
                    Spacer()
                    PrayerPill(name: L10n.Prayer.maghrib, status: log.maghrib) { togglePrayer("maghrib") }
                    Spacer()
                    PrayerPill(name: L10n.Prayer.isha, status: log.isha) { togglePrayer("isha") }
                }
            } else {
                // Skeleton placeholders while loading
                HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { i in
                        VStack(spacing: DS.Space.sm) {
                            Circle()
                                .fill(DS.Color.hairline)
                                .frame(width: 48, height: 48)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(DS.Color.hairline)
                                .frame(width: 32, height: 10)
                        }
                        if i < 4 { Spacer() }
                    }
                }
                .redacted(reason: .placeholder)
            }
        }
    }

    private func togglePrayer(_ key: String) {
        guard let log = viewModel.todayLog else { return }
        withAnimation(DS.Motion.tap) {
            switch key {
            case "fajr":    log.fajr = log.fajr == .prayed ? .notLogged : .prayed
            case "dhuhr":   log.dhuhr = log.dhuhr == .prayed ? .notLogged : .prayed
            case "asr":     log.asr = log.asr == .prayed ? .notLogged : .prayed
            case "maghrib": log.maghrib = log.maghrib == .prayed ? .notLogged : .prayed
            case "isha":    log.isha = log.isha == .prayed ? .notLogged : .prayed
            default: break
            }
        }
        try? modelContext.save()
        DS.Haptic.mediumTap()
    }

    // MARK: - Horizontal Widgets

    private var horizontalWidgets: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Space.md) {
                Color.clear.frame(width: DS.Space.sm)

                // Continue Reading Widget
                if let position = viewModel.lastReadPosition {
                    Button {
                        DS.Haptic.softTap()
                        onResumeReading?(position.mushafPage)
                    } label: {
                        continueReadingWidget(position)
                    }
                    .buttonStyle(WidgetButtonStyle())
                }

                // Daily Progress Widget
                dailyProgressWidget

                // Streak Widget
                if viewModel.readingStreakDays > 0 {
                    streakWidget
                }

                Color.clear.frame(width: DS.Space.sm)
            }
        }
    }

    private func continueReadingWidget(_ position: LastReadPosition) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack {
                Image(systemName: "book.fill")
                    .font(DS.Typography.alongSans(size: 13, weight: "Medium"))
                    .foregroundStyle(DS.Color.accent)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                            .fill(DS.Color.accentSoft)
                    )
                Spacer()
                Image(systemName: "arrow.right")
                    .font(DS.Typography.alongSans(size: 11, weight: "Bold"))
                    .foregroundStyle(DS.Color.accent.opacity(0.5))
                    .symbolEffect(.bounce, options: .repeating.speed(0.3))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.Dashboard.whereYouLeft)
                    .font(DS.Typography.alongSans(size: 9, weight: "Bold"))
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(1.5)
                Text(position.surahNameTurkish)
                    .font(DS.Typography.alongSans(size: 15, weight: "SemiBold"))
                    .foregroundStyle(DS.Color.textPrimary)
                    .lineLimit(1)
                Text("Sayfa \(position.mushafPage)")
                    .font(DS.Typography.alongSans(size: 12, weight: "Regular"))
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .frame(width: 160)
        .padding(DS.Space.lg)
        .dsGlass(.thin, cornerRadius: DS.Radius.lg)
        .dsShadow(DS.Shadow.premiumCard)
    }

    private var dailyProgressWidget: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(DS.Typography.alongSans(size: 13, weight: "Medium"))
                    .foregroundStyle(DS.Color.success)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                            .fill(DS.Color.success.opacity(0.1))
                    )
                Spacer()
                Text("\(Int(viewModel.quranProgressPercent * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Color.success)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.Dashboard.today)
                    .font(DS.Typography.alongSans(size: 9, weight: "Bold"))
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(1.5)
                Text("\(viewModel.pagesReadToday)/\(viewModel.dailyPageGoal) sayfa")
                    .font(DS.Typography.alongSans(size: 15, weight: "SemiBold"))
                    .foregroundStyle(DS.Color.textPrimary)

                DSProgressBar(
                    min(1.0, Double(viewModel.pagesReadToday) / Double(max(1, viewModel.dailyPageGoal))),
                    height: 4
                )
            }
        }
        .frame(width: 160)
        .padding(DS.Space.lg)
        .dsGlass(.thin, cornerRadius: DS.Radius.lg)
        .dsShadow(DS.Shadow.premiumCard)
    }

    private var streakWidget: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Image(systemName: "flame.fill")
                .font(DS.Typography.alongSans(size: 13, weight: "Medium"))
                .foregroundStyle(DS.Color.warning)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                        .fill(DS.Color.warning.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.Dashboard.continuity)
                    .font(DS.Typography.alongSans(size: 9, weight: "Bold"))
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(1.5)
                Text("\(viewModel.readingStreakDays)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(DS.Color.textPrimary)
                Text(L10n.Common.day)
                    .font(DS.Typography.alongSans(size: 12, weight: "Medium"))
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .frame(width: 120)
        .padding(DS.Space.lg)
        .dsGlass(.thin, cornerRadius: DS.Radius.lg)
        .dsShadow(DS.Shadow.premiumCard)
    }

    // MARK: - Verse of the Day

    @ViewBuilder
    private var verseOfTheDayCard: some View {
        if let verse = viewModel.verseOfTheDay {
            Button {
                DS.Haptic.softTap()
                onResumeReading?(verse.pageNumber)
            } label: {
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    HStack {
                        Label {
                            Text(L10n.Dashboard.verseOfDay)
                                .font(DS.Typography.alongSans(size: 11, weight: "SemiBold"))
                                .tracking(2)
                        } icon: {
                            Image(systemName: "sparkles")
                                .font(DS.Typography.alongSans(size: 10, weight: "Regular"))
                        }
                        .foregroundStyle(DS.Color.accent)

                        Spacer()

                        HStack(spacing: DS.Space.xs) {
                            Text("\(verse.surahId):\(verse.verseNumber)")
                                .font(DS.Typography.alongSans(size: 11, weight: "Medium"))
                                .foregroundStyle(DS.Color.textSecondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(DS.Color.accent.opacity(0.5))
                        }
                    }

                    Text(verse.textArabic)
                        .font(DS.Typography.arabicVerse)
                        .multilineTextAlignment(.trailing)
                        .lineSpacing(DS.Typography.LineSpacing.arabic)
                        .foregroundStyle(DS.Color.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Text(verse.textTranslation)
                        .font(DS.Typography.footnote)
                        .foregroundStyle(DS.Color.textSecondary)
                        .lineSpacing(DS.Typography.LineSpacing.body)

                    Text("— \(viewModel.verseOfTheDaySurahName)")
                        .font(DS.Typography.serifSource)
                        .foregroundStyle(DS.Color.accent.opacity(0.7))
                }
                .padding(DS.Space.lg)
                .dsGlass(.thin, cornerRadius: DS.Radius.lg)
                .dsShadow(DS.Shadow.premiumCard)
            }
            .buttonStyle(WidgetButtonStyle())
        }
    }

    // MARK: - Quick Actions Grid

    private var quickActionsGrid: some View {
        VStack(spacing: DS.Space.md) {
            HStack(spacing: DS.Space.md) {
                Button { onOpenRehber?() } label: {
                    quickActionCard(icon: "book.pages", title: L10n.Dashboard.guide, subtitle: L10n.Dashboard.guideSubtitle, tint: DS.Color.accent)
                }
                .buttonStyle(WidgetButtonStyle())

                NavigationLink {
                    KazaView()
                } label: {
                    quickActionCard(icon: "arrow.counterclockwise.circle.fill", title: L10n.Dashboard.kaza, subtitle: L10n.Dashboard.kazaSubtitle, tint: DS.Color.warning)
                }
            }

            HStack(spacing: DS.Space.md) {
                NavigationLink {
                    DuasView(container: container)
                } label: {
                    quickActionCard(icon: "hands.sparkles.fill", title: L10n.Dashboard.duas, subtitle: L10n.Dashboard.duasSubtitle, tint: DS.Color.success)
                }

                NavigationLink {
                    TrackerView(container: container)
                } label: {
                    quickActionCard(icon: "chart.bar.fill", title: L10n.Dashboard.tracker, subtitle: L10n.Dashboard.trackerSubtitle, tint: DS.Color.accent)
                }
            }
        }
    }

    private func quickActionCard(icon: String, title: String, subtitle: String, tint: SwiftUI.Color) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Image(systemName: icon)
                .font(DS.Typography.listTitle)
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.sm + 2, style: .continuous)
                        .fill(tint.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DS.Typography.displayBody)
                    .foregroundStyle(DS.Color.textPrimary)
                Text(subtitle)
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.lg)
        .dsGlass(.regular, cornerRadius: DS.Radius.lg)
        .dsShadow(DS.Shadow.premiumCard)
    }
}

// MARK: - Hijri Date Helper

extension DashboardView {
    static var hijriDateString: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.locale = Locale(identifier: "tr")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Widget Button Style

private struct WidgetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsPress(configuration.isPressed)
    }
}

// MARK: - Prayer Pill

private struct PrayerPill: View {
    let name: String
    let status: PrayerStatus
    let onTap: () -> Void

    private var isPrayed: Bool { status == .prayed }

    var body: some View {
        Button { onTap() } label: {
            VStack(spacing: DS.Space.sm) {
                ZStack {
                    if isPrayed {
                        Circle()
                            .fill(LinearGradient(colors: [DS.Color.accent, DS.Color.accent.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 48, height: 48)
                            // Premium glowing aura
                            .shadow(color: DS.Color.accent.opacity(0.5), radius: 10, y: 5)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            // Premium fluid bounce
                            .symbolEffect(.bounce, value: isPrayed)
                    } else {
                        Circle()
                            .fill(DS.Color.glassFill)
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .stroke(DS.Color.hairline, lineWidth: 1.5)
                            )
                    }
                }

                Text(name)
                    .font(DS.Typography.alongSans(size: 11, weight: "Bold"))
                    .foregroundStyle(isPrayed ? DS.Color.accent : DS.Color.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPrayed)
        .accessibilityLabel(L10n.Dashboard.prayerAccessibility(name: name, isPrayed: isPrayed))
        .accessibilityAddTraits(.isToggle)
    }
}

// MARK: - Preview

#Preview("Dashboard") {
    DSPreview { c in DashboardView(container: c) }
}
