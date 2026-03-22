import SwiftUI
import SwiftData

struct DhikrView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DhikrViewModel

    // Interaction state
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    @State private var showPresetPicker = false
    @State private var showHistory = false
    @State private var showTourComplete = false
    @State private var tourCount = 0

    // ── Organic Animation State ────────────────────────────
    @State private var counterScale: CGFloat = 1.0
    @State private var milestoneGlow: CGFloat = 0
    @State private var ringPulse: CGFloat = 1.0
    @State private var ringBreathing = false
    @State private var showParticles = false
    @State private var isAmbient = false
    @State private var ambientTask: Task<Void, Never>?
    @Environment(\.tabBarVisible) private var tabBarVisible
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: DhikrViewModel(container: container))
    }

    private let ringSize: CGFloat = 230

    // MARK: - Body

    var body: some View {
        ZStack {
            DS.Color.backgroundPrimary.ignoresSafeArea()

            // Ambient background pulse on each count
            Circle()
                .fill(DS.Color.accent.opacity(0.02))
                .scaleEffect(rippleScale * 0.6)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                topBar
                    .padding(.top, DS.Space.sm)
                    .opacity(isAmbient ? 0.3 : 1.0)

                Spacer()

                // Tour dots
                if tourCount > 0 {
                    tourIndicator
                        .padding(.bottom, DS.Space.md)
                }

                // Particle system for milestones
                ParticleSystem(isEmitting: $showParticles)
                    .frame(width: 240, height: 240)
                    .allowsHitTesting(false)
                    .overlay { ring }

                presetName
                    .padding(.top, DS.Space.lg)
                    .opacity(isAmbient ? 0.4 : 1.0)

                Spacer()

                // Hint
                if viewModel.currentCount == 0 && !isAmbient {
                    VStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(DS.Color.textSecondary.opacity(0.3))
                        Text("Dokun veya Aşağı Kaydır")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(DS.Color.textSecondary.opacity(0.3))
                            .tracking(1.5)
                            .textCase(.uppercase)
                    }
                    .padding(.bottom, DS.Space.lg)
                }

                bottomBar
                    .padding(.bottom, DS.Space.md + 60)
                    .opacity(isAmbient ? 0.3 : 1.0)
            }

            // Ripple
            Circle()
                .fill(DS.Color.accent.opacity(rippleOpacity))
                .scaleEffect(rippleScale)
                .frame(width: 50, height: 50)
                .allowsHitTesting(false)

            // Tour complete
            if showTourComplete {
                tourCompleteOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .animation(DS.Motion.ambient, value: isAmbient)
        .contentShape(Rectangle())
        .gesture(pullGesture)
        .onTapGesture { performCount() }
        .onAppear {
            DS.Haptic.prepare()
            tabBarVisible.wrappedValue = false
            if !reduceMotion { ringBreathing = true }
        }
        .onDisappear {
            tabBarVisible.wrappedValue = true
            ambientTask?.cancel()
            // Auto-save any in-progress session when leaving
            if viewModel.currentCount > 0 || tourCount > 0 {
                viewModel.saveSession(context: modelContext, tourCount: tourCount)
            }
        }
        .task {
            viewModel.loadPresets(context: modelContext)
            viewModel.loadSessionHistory(context: modelContext)
            if viewModel.selectedPreset == nil, let first = viewModel.presets.first {
                viewModel.selectPreset(first)
            }
        }
        .sheet(isPresented: $showPresetPicker) { pickerSheet }
        .sheet(isPresented: $showHistory) { historySheet }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { showPresetPicker = true } label: {
                HStack(spacing: 6) {
                    Text("Zikirmatik")
                        .font(DS.Typography.surahTitle)
                        .foregroundStyle(DS.Color.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(DS.Typography.alongSans(size: 9, weight: "Bold"))
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }

            Spacer()

            // Today total
            if viewModel.todayTotalCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(DS.Typography.alongSans(size: 10, weight: "Regular"))
                        .foregroundStyle(DS.Color.accent)
                    Text("\(viewModel.todayTotalCount)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(DS.Color.textSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(DS.Color.cardElevated))
            }

            Button { showHistory = true } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(DS.Color.cardElevated))
            }
            .accessibilityLabel("Geçmiş")
        }
        .padding(.horizontal, DS.Space.xl)
    }

    // MARK: - Tour Indicator

    private var tourIndicator: some View {
        HStack(spacing: DS.Space.sm) {
            ForEach(0..<min(tourCount, 7), id: \.self) { _ in
                Circle()
                    .fill(DS.Color.accent)
                    .frame(width: 6, height: 6)
            }
            if tourCount > 7 {
                Text("+\(tourCount - 7)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(DS.Color.accent)
            }
        }
        .padding(.horizontal, DS.Space.md)
        .padding(.vertical, DS.Space.xs)
        .background(Capsule().fill(DS.Color.accentSoft))
    }

    // MARK: - Ring

    private var ring: some View {
        let isMilestone = viewModel.currentCount > 0 && viewModel.currentCount % 33 == 0

        return ZStack {
            // Outer decorative ring — faint tick marks
            ForEach(0..<36, id: \.self) { i in
                let angle = Double(i) * 10.0
                let isMajorTick = i % 3 == 0
                Rectangle()
                    .fill(DS.Color.hairline.opacity(isMajorTick ? 0.5 : 0.2))
                    .frame(width: isMajorTick ? 1.5 : 0.5, height: isMajorTick ? 8 : 4)
                    .offset(y: -(ringSize / 2 + 12))
                    .rotationEffect(.degrees(angle))
            }

            // Track ring — subtle gradient
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [DS.Color.hairline.opacity(0.6), DS.Color.hairline.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 4
                )
                .frame(width: ringSize, height: ringSize)

            if let preset = viewModel.selectedPreset, preset.target > 0 {
                let pct = min(1.0, Double(viewModel.currentCount) / Double(preset.target))

                // Wide ambient glow trail
                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(
                        DS.Color.accent.opacity(isMilestone ? 0.4 : 0.18),
                        lineWidth: 20
                    )
                    .blur(radius: 12)
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .scaleEffect(ringPulse)
                    .animation(.easeOut(duration: 0.3), value: viewModel.currentCount)

                // Progress arc — rich angular gradient
                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                DS.Color.accent.opacity(0.4),
                                DS.Color.accent.opacity(0.8),
                                DS.Color.accent,
                                DS.Color.warning.opacity(0.9),
                                DS.Color.accent
                            ]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .scaleEffect(ringPulse)
                    .animation(.easeOut(duration: 0.3), value: viewModel.currentCount)

                // Endpoint dot
                if pct > 0.01 {
                    Circle()
                        .fill(DS.Color.accent)
                        .frame(width: 8, height: 8)
                        .shadow(color: DS.Color.accent.opacity(0.6), radius: 6)
                        .offset(y: -ringSize / 2)
                        .rotationEffect(.degrees(360 * pct - 90))
                        .animation(.easeOut(duration: 0.3), value: viewModel.currentCount)
                }
            }

            // Milestone warm glow background
            if milestoneGlow > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DS.Color.accent.opacity(milestoneGlow * 0.15),
                                DS.Color.accent.opacity(milestoneGlow * 0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: ringSize / 2 + 30
                        )
                    )
                    .frame(width: ringSize + 60, height: ringSize + 60)
            }

            // Number — organic scale animation
            VStack(spacing: 4) {
                Text("\(viewModel.currentCount)")
                    .font(.system(size: 64, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(DS.Color.textPrimary)
                    .contentTransition(.numericText())
                    .scaleEffect(counterScale)
                    .animation(.easeOut(duration: 0.12), value: viewModel.currentCount)

                if let preset = viewModel.selectedPreset {
                    HStack(spacing: 2) {
                        Rectangle()
                            .fill(DS.Color.accent.opacity(0.3))
                            .frame(width: 12, height: 0.5)
                        Text("\(preset.target)")
                            .font(.system(size: 13, weight: .light, design: .monospaced))
                            .foregroundStyle(DS.Color.textSecondary.opacity(0.6))
                        Rectangle()
                            .fill(DS.Color.accent.opacity(0.3))
                            .frame(width: 12, height: 0.5)
                    }
                }
            }
            .offset(y: isDragging ? min(dragOffset * 0.08, 12) : 0)
            .animation(.interactiveSpring, value: isDragging)
        }
        .dsBreathing(active: ringBreathing, scale: 1.015, duration: 4.0)
    }

    // MARK: - Preset Name

    private var presetName: some View {
        Group {
            if let preset = viewModel.selectedPreset {
                VStack(spacing: DS.Space.xs) {
                    Text(preset.title)
                        .font(DS.Typography.displayBody)
                        .foregroundStyle(DS.Color.textPrimary.opacity(0.7))

                    if let desc = viewModel.presetDescription {
                        Text(desc)
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            // Reset
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    // Auto-save before reset if there's data
                    if viewModel.currentCount > 0 || tourCount > 0 {
                        viewModel.saveSession(context: modelContext, tourCount: tourCount)
                        viewModel.loadSessionHistory(context: modelContext)
                    }
                    viewModel.reset()
                    tourCount = 0
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(DS.Typography.alongSans(size: 14, weight: "Medium"))
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(DS.Color.cardElevated))
            }
            .accessibilityLabel("Sıfırla")

            Spacer()

            // Counter + tour
            if let preset = viewModel.selectedPreset {
                VStack(spacing: 2) {
                    Text("\(viewModel.currentCount) / \(preset.target)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(DS.Color.textSecondary)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.12), value: viewModel.currentCount)

                    if tourCount > 0 {
                        Text("\(tourCount) tur")
                            .font(DS.Typography.chipLabel)
                            .foregroundStyle(DS.Color.accent)
                    }
                }
                .accessibilityLabel("\(viewModel.currentCount) / \(preset.target) sayım, \(tourCount) tur")
            }

            Spacer()

            // Preset switch
            Button { showPresetPicker = true } label: {
                Image(systemName: "list.bullet")
                    .font(DS.Typography.alongSans(size: 14, weight: "Medium"))
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(DS.Color.cardElevated))
            }
            .accessibilityLabel("Zikir Seç")
        }
        .padding(.horizontal, DS.Space.x2)
    }

    // MARK: - Tour Complete

    private var tourCompleteOverlay: some View {
        VStack(spacing: DS.Space.lg) {
            ZStack {
                // Expanding celebration rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(DS.Color.accent.opacity(0.08 - Double(i) * 0.02), lineWidth: 1)
                        .frame(width: CGFloat(90 + i * 25), height: CGFloat(90 + i * 25))
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DS.Color.accent.opacity(0.15),
                                DS.Color.accent.opacity(0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DS.Color.accent, DS.Color.accent.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, value: tourCount)
                    .shadow(color: DS.Color.accent.opacity(0.4), radius: 12)
            }

            VStack(spacing: DS.Space.sm) {
                Text(L10n.Dhikr.tourComplete)
                    .font(DS.Typography.displayBody)
                    .foregroundStyle(DS.Color.textPrimary)

                HStack(spacing: DS.Space.xs) {
                    Image(systemName: "rosette")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Color.accent)
                    Text("\(tourCount). tur")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(DS.Color.accent)
                }
            }
        }
        .padding(DS.Space.x2)
        .padding(.horizontal, DS.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.x2, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.x2, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            DS.Color.accent.opacity(0.3),
                            DS.Color.accent.opacity(0.05),
                            DS.Color.accent.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: DS.Color.accent.opacity(0.2), radius: 30, y: 10)
    }

    // MARK: - Pull Gesture

    private var pullGesture: some Gesture {
        DragGesture(minimumDistance: 15)
            .onChanged { v in
                if v.translation.height > 0 {
                    isDragging = true
                    dragOffset = v.translation.height
                }
            }
            .onEnded { v in
                isDragging = false
                dragOffset = 0
                if v.translation.height > 35 { performCount() }
            }
    }

    // MARK: - Count Logic

    private func resetAmbientTimer() {
        ambientTask?.cancel()
        if isAmbient {
            withAnimation(DS.Motion.ambient) { isAmbient = false }
        }
        ambientTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3.0))
            guard !Task.isCancelled, viewModel.currentCount > 0 else { return }
            withAnimation(DS.Motion.ambient) { isAmbient = true }
        }
    }

    private func performCount() {
        resetAmbientTimer()
        withAnimation(.easeOut(duration: 0.12)) { viewModel.increment() }

        // ── Organic scale pulse on every count ─────────────
        withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
            counterScale = 1.12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                counterScale = 1.0
            }
        }

        let c = viewModel.currentCount
        if let p = viewModel.selectedPreset, c == p.target {
            // ── Tour complete ────────────────────────────────
            tourCount += 1
            DS.Haptic.goalReached()

            // Big ring pulse
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                ringPulse = 1.08
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    ringPulse = 1.0
                }
            }

            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showTourComplete = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showTourComplete = false
                }
                withAnimation(.easeOut(duration: 0.2)) {
                    viewModel.currentCount = 0
                }
            }
        } else if c > 0 && c % 33 == 0 {
            // ── Milestone (33, 66, 99) ───────────────────────
            DS.Haptic.dhikrMilestone()
            showParticles = true

            // Heavier scale punch at milestones
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                counterScale = 1.25
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    counterScale = 1.0
                }
            }

            // Green milestone glow
            withAnimation(.easeOut(duration: 0.15)) {
                milestoneGlow = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 0.5)) {
                    milestoneGlow = 0
                }
            }

            // Ring bump
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                ringPulse = 1.06
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    ringPulse = 1.0
                }
            }
        } else {
            DS.Haptic.dhikrTap()
        }

        fireRipple()
    }

    private func fireRipple() {
        rippleScale = 0.2
        rippleOpacity = 0.15
        withAnimation(.easeOut(duration: 0.55)) {
            rippleScale = 5.0
            rippleOpacity = 0
        }
    }

    // MARK: - Preset Picker

    private var pickerSheet: some View {
        VStack(spacing: 0) {
            DSSheetHeader("Zikir Seç", onDismiss: { showPresetPicker = false })

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.presets, id: \.title) { preset in
                        let isSelected = viewModel.selectedPreset?.title == preset.title
                        Button {
                            if viewModel.currentCount > 0 || tourCount > 0 {
                                viewModel.saveSession(context: modelContext, tourCount: tourCount)
                                viewModel.loadSessionHistory(context: modelContext)
                            }
                            viewModel.selectPreset(preset)
                            tourCount = 0
                            showPresetPicker = false
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(preset.title)
                                        .font(DS.Typography.body)
                                        .foregroundStyle(DS.Color.textPrimary)
                                    Text("Hedef: \(preset.target)")
                                        .font(DS.Typography.captionSm)
                                        .foregroundStyle(DS.Color.textSecondary)
                                }
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(DS.Color.accent)
                                }
                            }
                            .padding(.horizontal, DS.Space.lg)
                            .padding(.vertical, DS.Space.lg)
                            .background(isSelected ? DS.Color.accentSoft : .clear)
                        }

                        Hairline().padding(.horizontal, DS.Space.lg)
                    }
                }
            }
        }
        .background(DS.Color.backgroundPrimary)
        .presentationDetents([.medium])
    }

    // MARK: - History

    private var historySheet: some View {
        VStack(spacing: 0) {
            DSSheetHeader("Zikir Geçmişi", onDismiss: { showHistory = false })

            if viewModel.recentSessions.isEmpty {
                SKNEmptyState(
                    icon: "clock",
                    title: L10n.Dhikr.noHistory,
                    message: L10n.Dhikr.noHistoryMessage
                )
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Space.lg) {
                        // Summary card
                        DSCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(L10n.Dhikr.todayTotal)
                                        .font(DS.Typography.captionSm)
                                        .foregroundStyle(DS.Color.textSecondary)
                                    Text("\(viewModel.todayTotalCount) zikir")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(DS.Color.accent)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Oturum")
                                        .font(DS.Typography.captionSm)
                                        .foregroundStyle(DS.Color.textSecondary)
                                    Text("\(viewModel.todaySessionCount)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(DS.Color.textPrimary)
                                }
                            }
                        }

                        // Sessions
                        DSSectionHeader("Son Oturumlar", serif: true)

                        ForEach(viewModel.recentSessions, id: \.date) { session in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(session.presetTitle)
                                        .font(DS.Typography.body)
                                        .foregroundStyle(DS.Color.textPrimary)
                                    Text(session.date, format: .dateTime.day().month().hour().minute())
                                        .font(DS.Typography.captionSm)
                                        .foregroundStyle(DS.Color.textSecondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 3) {
                                    Text("\(session.count)")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundStyle(DS.Color.accent)
                                    if session.durationSeconds > 0 {
                                        let mins = session.durationSeconds / 60
                                        let secs = session.durationSeconds % 60
                                        Text(mins > 0 ? "\(mins)dk \(secs)sn" : "\(secs)sn")
                                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                                            .foregroundStyle(DS.Color.textSecondary)
                                    }
                                }
                            }
                            .padding(.vertical, DS.Space.sm)

                            Hairline()
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.vertical, DS.Space.lg)
                }
            }
        }
        .background(DS.Color.backgroundPrimary)
        .presentationDetents([.large])
    }
}

// MARK: - Preview

#Preview("Dhikr") {
    DSPreview { c in DhikrView(container: c) }
}
