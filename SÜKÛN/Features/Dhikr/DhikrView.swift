import SwiftUI
import SwiftData

struct DhikrView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DhikrViewModel
    @State private var isPressed = false
    @State private var showGoalRing = false

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: DhikrViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Space.xl) {
                // Preset selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Space.md) {
                        ForEach(viewModel.presets, id: \.title) { preset in
                            let selected = viewModel.selectedPreset?.title == preset.title
                            Button {
                                viewModel.selectPreset(preset)
                            } label: {
                                VStack(spacing: DS.Space.xs) {
                                    Text(preset.title)
                                        .font(DS.Typography.caption)
                                        .padding(.horizontal, DS.Space.lg)
                                        .padding(.vertical, DS.Space.sm)
                                        .foregroundStyle(
                                            selected
                                                ? DS.Color.backgroundPrimary
                                                : DS.Color.textPrimary
                                        )
                                        .background(
                                            selected
                                                ? DS.Color.accent
                                                : DS.Color.backgroundSecondary,
                                            in: Capsule()
                                        )
                                    AccentUnderline(active: selected)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                }

                Spacer()

                // Counter display
                VStack(spacing: DS.Space.sm) {
                    Text("\(viewModel.currentCount)")
                        .font(.system(size: 80, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .foregroundStyle(DS.Color.textPrimary)

                    if let preset = viewModel.selectedPreset {
                        Text("/ \(preset.target)")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }

                Spacer()

                // Counter button with tap animation
                Button {
                    withAnimation(DS.Motion.tap) {
                        viewModel.increment()
                    }
                    DS.Haptic.dhikrTap()
                    checkGoal()
                } label: {
                    ZStack {
                        // Goal ring
                        Circle()
                            .stroke(DS.Color.accent.opacity(showGoalRing ? 0.7 : 0), lineWidth: 1)
                            .frame(width: 132, height: 132)

                        Circle()
                            .fill(DS.Color.accent)
                            .frame(width: 120, height: 120)
                            .shadow(
                                color: .black.opacity(isPressed ? 0.12 : 0.06),
                                radius: isPressed ? 2 : 4,
                                y: isPressed ? 1 : 2
                            )
                            .overlay {
                                Image(systemName: "hand.tap.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(DS.Color.backgroundPrimary)
                            }
                            .scaleEffect(isPressed ? 0.965 : 1.0)
                    }
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(DS.Motion.tap) { isPressed = true }
                        }
                        .onEnded { _ in
                            withAnimation(DS.Motion.tap) { isPressed = false }
                        }
                )

                // Actions
                HStack(spacing: DS.Space.x2) {
                    Button("Reset") {
                        viewModel.reset()
                    }
                    .font(DS.Typography.body)
                    .foregroundStyle(DS.Color.textSecondary)

                    Button("Save") {
                        viewModel.saveSession(context: modelContext)
                    }
                    .font(DS.Typography.body)
                    .foregroundStyle(DS.Color.accent)
                    .disabled(viewModel.currentCount == 0)
                }
                .padding(.bottom, DS.Space.lg)
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Dhikr")
            .task {
                viewModel.loadPresets(context: modelContext)
            }
        }
    }

    private func checkGoal() {
        guard let preset = viewModel.selectedPreset,
              viewModel.currentCount >= preset.target,
              viewModel.currentCount == preset.target else { return }
        DS.Haptic.goalReached()
        withAnimation(.easeIn(duration: 0.15)) {
            showGoalRing = true
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
            showGoalRing = false
        }
    }
}
