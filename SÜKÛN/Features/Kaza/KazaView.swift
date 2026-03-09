import SwiftUI
import SwiftData

struct KazaView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = KazaViewModel()
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Activity rings hero
                    activityRingsHero
                        .padding(.top, DS.Space.xl)
                        .padding(.horizontal, DS.Space.lg)
                        .dsAppear(loaded: appeared, index: 0)

                    // Prayer counters
                    LazyVStack(spacing: DS.Space.md) {
                        ForEach(Array(KazaPrayerType.allCases.enumerated()), id: \.element) { idx, prayer in
                            kazaRow(prayer)
                                .dsAppear(loaded: appeared, index: idx + 1)
                        }
                    }
                    .padding(.top, DS.Space.x2)
                    .padding(.horizontal, DS.Space.lg)

                    // Info text
                    infoSection
                        .padding(.top, DS.Space.x3)
                        .padding(.horizontal, DS.Space.lg)
                        .dsAppear(loaded: appeared, index: 7)

                    Spacer(minLength: DS.Space.x4)
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Kaza Takibi")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.load(context: modelContext)
                withAnimation(DS.Motion.slowReveal) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Activity Rings Hero

    private var activityRingsHero: some View {
        VStack(spacing: DS.Space.lg) {
            Text("TOPLAM KAZA")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(3)

            // Overlapping activity rings
            ZStack {
                ForEach(Array(KazaPrayerType.allCases.enumerated()), id: \.element) { idx, prayer in
                    let count = viewModel.count(for: prayer)
                    // Normalize: progress based on relative to max among all prayers
                    let totalMax = maxCountAcrossPrayers()
                    let pct = totalMax > 0 ? min(1.0, Double(count) / Double(totalMax)) : 0

                    ActivityRing(
                        progress: pct,
                        color: ringColor(for: idx),
                        lineWidth: 8,
                        size: CGFloat(180 - idx * 26)
                    )
                }

                // Center counter
                VStack(spacing: 2) {
                    Text("\(viewModel.kazaPrayer?.totalCount ?? 0)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(DS.Color.textPrimary)
                        .contentTransition(.numericText())
                        .animation(DS.Motion.countdown, value: viewModel.kazaPrayer?.totalCount)

                    Text("namaz")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
            .frame(height: 200)

            // Ring legend
            ringLegend
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.xl)
        .padding(.horizontal, DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        )
    }

    private var ringLegend: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DS.Space.sm) {
            ForEach(Array(KazaPrayerType.allCases.enumerated()), id: \.element) { idx, prayer in
                HStack(spacing: 4) {
                    Circle()
                        .fill(ringColor(for: idx))
                        .frame(width: 6, height: 6)
                    Text(prayer.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(DS.Color.textSecondary)
                    Text("\(viewModel.count(for: prayer))")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(DS.Color.textPrimary)
                }
            }
        }
    }

    private func maxCountAcrossPrayers() -> Int {
        KazaPrayerType.allCases.map { viewModel.count(for: $0) }.max() ?? 1
    }

    private func ringColor(for index: Int) -> Color {
        let colors: [Color] = [
            .red,
            .orange,
            DS.Color.accent,
            DS.Color.success,
            .cyan,
            .purple
        ]
        return colors[index % colors.count]
    }

    // MARK: - Kaza Row

    private func kazaRow(_ prayer: KazaPrayerType) -> some View {
        let count = viewModel.count(for: prayer)
        let idx = KazaPrayerType.allCases.firstIndex(of: prayer) ?? 0

        return HStack(spacing: DS.Space.lg) {
            // Prayer icon + name with mini ring
            HStack(spacing: DS.Space.md) {
                // Mini activity ring as icon
                ZStack {
                    Circle()
                        .stroke(ringColor(for: idx).opacity(0.15), lineWidth: 3)
                        .frame(width: 32, height: 32)

                    let totalMax = maxCountAcrossPrayers()
                    let pct = totalMax > 0 ? min(1.0, Double(count) / Double(totalMax)) : 0
                    Circle()
                        .trim(from: 0, to: pct)
                        .stroke(ringColor(for: idx), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(-90))
                        .animation(DS.Motion.standard, value: count)

                    Image(systemName: prayer.icon)
                        .font(.system(size: 11))
                        .foregroundStyle(ringColor(for: idx))
                }

                Text(prayer.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DS.Color.textPrimary)
            }

            Spacer()

            // Counter controls
            HStack(spacing: DS.Space.lg) {
                // Decrement button
                Button {
                    withAnimation(DS.Motion.tap) {
                        viewModel.decrement(prayer, context: modelContext)
                    }
                    DS.Haptic.softTap()
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(DS.Color.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(DS.Color.backgroundPrimary)
                        )
                }
                .disabled(count <= 0)
                .opacity(count <= 0 ? 0.3 : 1)

                // Count
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Color.textPrimary)
                    .frame(minWidth: 50)
                    .contentTransition(.numericText())
                    .animation(DS.Motion.countdown, value: count)

                // Increment button
                Button {
                    withAnimation(DS.Motion.tap) {
                        viewModel.increment(prayer, context: modelContext)
                    }
                    DS.Haptic.mediumTap()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(DS.Color.accent)
                        )
                }
            }
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.vertical, DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Label {
                Text("Bilgilendirme")
                    .font(.system(size: 12, weight: .semibold))
            } icon: {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
            }
            .foregroundStyle(DS.Color.accent)

            Text("Kaza namazlarınızı buradan takip edebilirsiniz. Her kıldığınız kaza namazından sonra ilgili namaz sayısını bir azaltın.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(DS.Color.textSecondary)
                .lineSpacing(4)
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                .fill(DS.Color.accentSoft)
        )
    }
}

// MARK: - Activity Ring Component

private struct ActivityRing: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 8
    var size: CGFloat = 120

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(color.opacity(0.12), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color.opacity(0.6), color]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * animatedProgress)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // End cap glow
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
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
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
