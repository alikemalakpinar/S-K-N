import SwiftUI
import SwiftData
import CoreLocation

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel
    var onOpenRehber: (() -> Void)?
    private let container: DependencyContainer

    init(container: DependencyContainer, onOpenRehber: (() -> Void)? = nil) {
        self.container = container
        _viewModel = State(initialValue: DashboardViewModel(container: container))
        self.onOpenRehber = onOpenRehber
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

                    // Quick action
                    rehberCard
                        .padding(.top, DS.Space.xl)
                        .padding(.horizontal, DS.Space.lg)

                    Spacer(minLength: DS.Space.x4)
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Sükûn")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadTodayData(context: modelContext)

                // Load next prayer countdown from location
                await container.locationService.requestPermission()
                do {
                    let coords = try await container.locationService.currentCoordinates()
                    let descriptor = FetchDescriptor<UserSetting>(predicate: #Predicate { $0.id == "default" })
                    let settings = (try? modelContext.fetch(descriptor))?.first
                    await viewModel.loadNextPrayer(
                        latitude: coords.latitude,
                        longitude: coords.longitude,
                        method: settings?.calculationMethod ?? "Turkey",
                        asrMethod: settings?.asrMethod ?? "hanafi"
                    )
                } catch {
                    // Location unavailable — countdown stays in placeholder state
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
