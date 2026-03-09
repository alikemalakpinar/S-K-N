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
                    // Greeting + location header
                    greetingHeader
                        .padding(.top, DS.Space.lg)
                        .padding(.horizontal, DS.Space.lg)

                    // Giant typographic countdown — THE HERO
                    countdownHero
                        .padding(.top, DS.Space.md)

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

                    Spacer(minLength: DS.Space.x4 + 60)
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sükûn")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(DS.Color.textPrimary)
                        .tracking(-0.3)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(container: container)
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(DS.Color.textSecondary)
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
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DS.Color.accent)
                    .symbolEffect(.pulse, options: .repeating.speed(0.3))

                Text(viewModel.greeting)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.Color.textSecondary)
            }

            Text(viewModel.locationName.isEmpty ? "Konum alınıyor..." : viewModel.locationName)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(DS.Color.textPrimary)
                .tracking(-0.8)
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
                        label: "SAAT",
                        opacity: 0.08
                    )
                    countdownBand(
                        value: String(format: "%02d", minutes),
                        label: "DAKİKA",
                        opacity: 0.25
                    )
                    countdownBand(
                        value: String(format: "%02d", seconds),
                        label: "SANİYE",
                        opacity: 0.90
                    )

                    // Prayer info row
                    HStack(alignment: .firstTextBaseline) {
                        Text(viewModel.nextPrayerName.uppercased())
                            .font(.system(size: 12, weight: .bold))
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
                    countdownBand(value: "--", label: "SAAT", opacity: 0.08)
                    countdownBand(value: "--", label: "DAKİKA", opacity: 0.25)
                    countdownBand(value: "--", label: "SANİYE", opacity: 0.90)
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
                .font(.system(size: 260, weight: .black).width(.condensed))
                .foregroundStyle(DS.Color.textPrimary.opacity(opacity))
                .tracking(-12)
                .lineLimit(1)
                .fixedSize()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, DS.Space.sm)

            VStack {
                HStack {
                    Spacer()
                    Text(label)
                        .font(.system(size: 10, weight: .bold))
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
                Text("GÜNÜN NAMAZLARI")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(3)

                Spacer()

                Text("\(viewModel.prayedCount)/5")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Color.accent)
            }

            if let log = viewModel.todayLog {
                HStack(spacing: 0) {
                    PrayerPill(name: "Sabah", status: log.fajr) { togglePrayer("fajr") }
                    Spacer()
                    PrayerPill(name: "Öğle", status: log.dhuhr) { togglePrayer("dhuhr") }
                    Spacer()
                    PrayerPill(name: "İkindi", status: log.asr) { togglePrayer("asr") }
                    Spacer()
                    PrayerPill(name: "Akşam", status: log.maghrib) { togglePrayer("maghrib") }
                    Spacer()
                    PrayerPill(name: "Yatsı", status: log.isha) { togglePrayer("isha") }
                }
            } else {
                HStack(spacing: 0) {
                    PrayerPill(name: "Sabah", status: .notLogged) {}
                    Spacer()
                    PrayerPill(name: "Öğle", status: .notLogged) {}
                    Spacer()
                    PrayerPill(name: "İkindi", status: .notLogged) {}
                    Spacer()
                    PrayerPill(name: "Akşam", status: .notLogged) {}
                    Spacer()
                    PrayerPill(name: "Yatsı", status: .notLogged) {}
                }
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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.Color.accent)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(DS.Color.accent.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("KALDIĞIN YER")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(1.5)
                Text(position.surahNameTurkish)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DS.Color.textPrimary)
                    .lineLimit(1)
                Text("Sayfa \(position.mushafPage)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .frame(width: 160)
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(DS.Color.glassBorder, lineWidth: 0.5)
        )
    }

    private var dailyProgressWidget: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.Color.accent)
                Spacer()
                Text("\(Int(viewModel.quranProgressPercent * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Color.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("BUGÜN")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(1.5)
                Text("\(viewModel.pagesReadToday)/\(viewModel.dailyPageGoal) sayfa")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DS.Color.textPrimary)

                // Mini progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(DS.Color.hairline).frame(height: 4)
                        Capsule().fill(DS.Color.accent).frame(
                            width: geo.size.width * min(1.0, Double(viewModel.pagesReadToday) / Double(max(1, viewModel.dailyPageGoal))),
                            height: 4
                        )
                    }
                }
                .frame(height: 4)
            }
        }
        .frame(width: 160)
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(DS.Color.glassBorder, lineWidth: 0.5)
        )
    }

    private var streakWidget: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DS.Color.accent)

            VStack(alignment: .leading, spacing: 3) {
                Text("DEVAMLILIK")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(1.5)
                Text("\(viewModel.readingStreakDays)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(DS.Color.textPrimary)
                Text("gün")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .frame(width: 120)
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(DS.Color.glassBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Verse of the Day

    @ViewBuilder
    private var verseOfTheDayCard: some View {
        if let verse = viewModel.verseOfTheDay {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                HStack {
                    Label {
                        Text("GÜNÜN AYETİ")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                    } icon: {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(DS.Color.accent)

                    Spacer()

                    Text("\(verse.surahId):\(verse.verseNumber)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DS.Color.textSecondary)
                }

                Text(verse.textArabic)
                    .font(.system(size: 26, weight: .regular))
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(14)
                    .foregroundStyle(DS.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(verse.textTranslation)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DS.Color.textSecondary)
                    .lineSpacing(5)

                Text("— \(viewModel.verseOfTheDaySurahName)")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .italic()
                    .foregroundStyle(DS.Color.accent.opacity(0.7))
            }
            .padding(DS.Space.lg)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(DS.Color.quranCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(DS.Color.ornamentLine, lineWidth: 0.5)
            )
        }
    }

    // MARK: - Quick Actions Grid

    private var quickActionsGrid: some View {
        VStack(spacing: DS.Space.md) {
            HStack(spacing: DS.Space.md) {
                Button { onOpenRehber?() } label: {
                    quickActionCard(icon: "book.pages", title: "Rehber", subtitle: "Temel bilgiler")
                }
                .buttonStyle(WidgetButtonStyle())

                NavigationLink {
                    KazaView()
                } label: {
                    quickActionCard(icon: "arrow.counterclockwise.circle.fill", title: "Kaza", subtitle: "Kaza takibi")
                }
            }

            HStack(spacing: DS.Space.md) {
                NavigationLink {
                    DuasView(container: container)
                } label: {
                    quickActionCard(icon: "hands.sparkles.fill", title: "Dualar", subtitle: "Dua ara")
                }

                NavigationLink {
                    TrackerView(container: container)
                } label: {
                    quickActionCard(icon: "chart.bar.fill", title: "Takip", subtitle: "İstatistikler")
                }
            }
        }
    }

    private func quickActionCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(DS.Color.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DS.Color.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
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
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isPrayed ? DS.Color.accent : DS.Color.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPrayed)
        .accessibilityLabel("\(name) namazı, \(isPrayed ? "kılındı" : "kılınmadı")")
        .accessibilityAddTraits(.isToggle)
    }
}
