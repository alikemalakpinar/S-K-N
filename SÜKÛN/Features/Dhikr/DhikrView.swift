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

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: DhikrViewModel(container: container))
    }

    private let ringSize: CGFloat = 230

    // MARK: - Body

    var body: some View {
        ZStack {
            DS.Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.top, DS.Space.sm)

                Spacer()

                // Tour dots
                if tourCount > 0 {
                    tourIndicator
                        .padding(.bottom, DS.Space.md)
                }

                ring
                presetName
                    .padding(.top, DS.Space.lg)

                Spacer()

                // Hint
                if viewModel.currentCount == 0 {
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
                    .padding(.bottom, DS.Space.md)
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
        .contentShape(Rectangle())
        .gesture(pullGesture)
        .onTapGesture { performCount() }
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
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DS.Color.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }

            Spacer()

            // Today total
            if viewModel.todayTotalCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.orange)
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
        ZStack {
            // Track
            Circle()
                .stroke(DS.Color.hairline, lineWidth: 4)
                .frame(width: ringSize, height: ringSize)

            if let preset = viewModel.selectedPreset, preset.target > 0 {
                let pct = min(1.0, Double(viewModel.currentCount) / Double(preset.target))

                // Progress arc
                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(DS.Color.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: viewModel.currentCount)

                // Glow
                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(DS.Color.accent.opacity(0.2), lineWidth: 12)
                    .blur(radius: 8)
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: viewModel.currentCount)
            }

            // Number
            VStack(spacing: 2) {
                Text("\(viewModel.currentCount)")
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(DS.Color.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.12), value: viewModel.currentCount)

                if let preset = viewModel.selectedPreset {
                    Text("/ \(preset.target)")
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
            .offset(y: isDragging ? min(dragOffset * 0.08, 12) : 0)
            .animation(.interactiveSpring, value: isDragging)
        }
    }

    // MARK: - Preset Name

    private var presetName: some View {
        Group {
            if let preset = viewModel.selectedPreset {
                VStack(spacing: DS.Space.xs) {
                    Text(preset.title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(DS.Color.textPrimary.opacity(0.7))
                        .tracking(0.5)

                    if let desc = viewModel.presetDescription {
                        Text(desc)
                            .font(.system(size: 11))
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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(DS.Color.cardElevated))
            }

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
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(DS.Color.accent)
                    }
                }
            }

            Spacer()

            // Preset switch
            Button { showPresetPicker = true } label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(DS.Color.cardElevated))
            }
        }
        .padding(.horizontal, DS.Space.x2)
    }

    // MARK: - Tour Complete

    private var tourCompleteOverlay: some View {
        VStack(spacing: DS.Space.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(DS.Color.accent)
            Text("Tur Tamamlandı!")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DS.Color.textPrimary)
            Text("\(tourCount). tur")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(DS.Color.textSecondary)
        }
        .padding(DS.Space.x2)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.1), radius: 20)
        )
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

    private func performCount() {
        withAnimation(.easeOut(duration: 0.12)) { viewModel.increment() }

        let c = viewModel.currentCount
        if let p = viewModel.selectedPreset, c == p.target {
            // Tour complete — auto-save this tour
            tourCount += 1
            DS.Haptic.goalReached()

            // Auto-save immediately on tour completion
            viewModel.saveSession(context: modelContext, tourCount: 0)
            viewModel.loadSessionHistory(context: modelContext)

            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showTourComplete = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showTourComplete = false
                }
                withAnimation(.easeOut(duration: 0.2)) {
                    viewModel.currentCount = 0
                    viewModel.isSessionActive = false
                }
            }
        } else if c > 0, c % 33 == 0 {
            DS.Haptic.dhikrMilestone()
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
        NavigationStack {
            List {
                ForEach(viewModel.presets, id: \.title) { preset in
                    Button {
                        // Auto-save current session before switching
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
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(DS.Color.textPrimary)
                                Text("Hedef: \(preset.target)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(DS.Color.textSecondary)
                            }
                            Spacer()
                            if viewModel.selectedPreset?.title == preset.title {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(DS.Color.accent)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(DS.Color.backgroundPrimary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Zikir Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") { showPresetPicker = false }
                        .foregroundStyle(DS.Color.accent)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - History

    private var historySheet: some View {
        NavigationStack {
            Group {
                if viewModel.recentSessions.isEmpty {
                    ContentUnavailableView(
                        "Kayıt Yok",
                        systemImage: "clock",
                        description: Text("Zikir oturumlarınız burada görünecek")
                    )
                } else {
                    List {
                        // Summary
                        Section {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Bugün Toplam")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(DS.Color.textSecondary)
                                    Text("\(viewModel.todayTotalCount) zikir")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(DS.Color.accent)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Oturum")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(DS.Color.textSecondary)
                                    Text("\(viewModel.todaySessionCount)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(DS.Color.textPrimary)
                                }
                            }
                            .padding(.vertical, DS.Space.sm)
                            .listRowBackground(DS.Color.cardElevated)
                        }

                        Section("Son Oturumlar") {
                            ForEach(viewModel.recentSessions, id: \.date) { session in
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(session.presetTitle)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(DS.Color.textPrimary)
                                        Text(session.date, format: .dateTime.day().month().hour().minute())
                                            .font(.system(size: 11))
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
                                .padding(.vertical, 2)
                                .listRowBackground(DS.Color.backgroundPrimary)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Zikir Geçmişi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") { showHistory = false }
                        .foregroundStyle(DS.Color.accent)
                }
            }
        }
        .presentationDetents([.large])
    }
}
