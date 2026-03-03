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
    @State private var showHint = true
    @State private var showPresetPicker = false
    @State private var showSaveConfirm = false

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: DhikrViewModel(container: container))
    }

    // MARK: - Palette (immersive dark)

    private let bg       = Color(red: 0.06, green: 0.06, blue: 0.08)
    private let surface  = Color(red: 0.11, green: 0.11, blue: 0.13)
    private let glow     = Color(red: 0.82, green: 0.70, blue: 0.38)
    private let cream    = Color(red: 0.93, green: 0.91, blue: 0.87)
    private let ghost    = Color(red: 0.93, green: 0.91, blue: 0.87).opacity(0.45)
    private let ringSize: CGFloat = 250

    // MARK: - Body

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.top, DS.Space.sm)

                Spacer()

                ring
                presetName
                    .padding(.top, DS.Space.xl)

                Spacer()

                hintLabel
                    .padding(.bottom, DS.Space.xl)

                bottomBar
                    .padding(.bottom, DS.Space.md)
            }

            // Ripple overlay
            Circle()
                .fill(glow.opacity(rippleOpacity))
                .scaleEffect(rippleScale)
                .frame(width: 50, height: 50)
                .allowsHitTesting(false)
        }
        .preferredColorScheme(.dark)
        .contentShape(Rectangle())
        .gesture(pullGesture)
        .onTapGesture { performCount() }
        .task {
            viewModel.loadPresets(context: modelContext)
            if viewModel.selectedPreset == nil, let first = viewModel.presets.first {
                viewModel.selectPreset(first)
            }
        }
        .sheet(isPresented: $showPresetPicker) { pickerSheet }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { showPresetPicker = true } label: {
                HStack(spacing: 6) {
                    Text("Zikirmatik")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(cream)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(ghost)
                }
            }
            Spacer()
            Button { showPresetPicker = true } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ghost)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(surface))
            }
        }
        .padding(.horizontal, DS.Space.xl)
    }

    // MARK: - Progress Ring + Counter

    private var ring: some View {
        ZStack {
            // Track
            Circle()
                .stroke(surface, lineWidth: 3)
                .frame(width: ringSize, height: ringSize)

            // Glow halo (behind progress)
            if let preset = viewModel.selectedPreset, preset.target > 0 {
                let pct = min(1.0, Double(viewModel.currentCount) / Double(preset.target))

                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(glow.opacity(0.25), lineWidth: 12)
                    .blur(radius: 10)
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: viewModel.currentCount)

                // Progress arc
                Circle()
                    .trim(from: 0, to: pct)
                    .stroke(
                        AngularGradient(
                            colors: [glow.opacity(0.2), glow, glow.opacity(0.7)],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: viewModel.currentCount)
            }

            // Number
            VStack(spacing: 2) {
                Text("\(viewModel.currentCount)")
                    .font(.system(size: 68, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(cream)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.12), value: viewModel.currentCount)

                if let preset = viewModel.selectedPreset {
                    Text("/ \(preset.target)")
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundStyle(ghost)
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
                Text(preset.title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(cream.opacity(0.7))
                    .tracking(0.5)
            }
        }
    }

    // MARK: - Hint

    private var hintLabel: some View {
        VStack(spacing: 6) {
            Image(systemName: "chevron.compact.down")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(ghost.opacity(showHint ? 0.5 : 0))

            Text("Aşağı Kaydır")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(ghost.opacity(showHint ? 0.35 : 0))
                .tracking(2)
                .textCase(.uppercase)
        }
        .opacity(viewModel.currentCount == 0 ? 1 : 0.2)
        .animation(.easeInOut(duration: 0.4), value: viewModel.currentCount)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            // Reset
            Button {
                withAnimation(.easeOut(duration: 0.2)) { viewModel.reset() }
                showHint = true
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(ghost)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(surface))
            }

            Spacer()

            // Counter
            if let preset = viewModel.selectedPreset {
                Text("\(viewModel.currentCount) / \(preset.target)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(ghost)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.12), value: viewModel.currentCount)
            }

            Spacer()

            // Save
            Button {
                viewModel.saveSession(context: modelContext)
                showSaveConfirm = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showSaveConfirm = false }
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.currentCount > 0 ? glow : surface)
                        .frame(width: 44, height: 44)
                    Image(systemName: showSaveConfirm ? "checkmark" : "square.and.arrow.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(viewModel.currentCount > 0 ? bg : ghost)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .disabled(viewModel.currentCount == 0)
        }
        .padding(.horizontal, DS.Space.x2)
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
            DS.Haptic.goalReached()
        } else if c > 0, c % 33 == 0 {
            DS.Haptic.dhikrMilestone()
        } else {
            DS.Haptic.dhikrTap()
        }

        fireRipple()
        if showHint { withAnimation(.easeOut(duration: 0.3)) { showHint = false } }
    }

    private func fireRipple() {
        rippleScale = 0.2
        rippleOpacity = 0.2
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
                        viewModel.selectPreset(preset)
                        showPresetPicker = false
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(preset.title)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(cream)
                                Text("Hedef: \(preset.target)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(ghost)
                            }
                            Spacer()
                            if viewModel.selectedPreset?.title == preset.title {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(glow)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(bg)
            .navigationTitle("Zikir Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") { showPresetPicker = false }
                        .foregroundStyle(glow)
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }
}
