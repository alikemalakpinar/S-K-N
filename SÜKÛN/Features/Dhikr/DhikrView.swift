import SwiftUI
import SwiftData

struct DhikrView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DhikrViewModel

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: DhikrViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Preset selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.presets, id: \.title) { preset in
                            Button {
                                viewModel.selectPreset(preset)
                            } label: {
                                Text(preset.title)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.selectedPreset?.title == preset.title
                                            ? Color.accentColor
                                            : Color.secondary.opacity(0.2),
                                        in: Capsule()
                                    )
                                    .foregroundStyle(
                                        viewModel.selectedPreset?.title == preset.title
                                            ? .white
                                            : .primary
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Counter display
                VStack(spacing: 8) {
                    Text("\(viewModel.currentCount)")
                        .font(.system(size: 80, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())

                    if let preset = viewModel.selectedPreset {
                        Text("/ \(preset.target)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Counter button
                Button {
                    withAnimation(.snappy(duration: 0.1)) {
                        viewModel.increment()
                    }
                } label: {
                    Circle()
                        .fill(.accent)
                        .frame(width: 120, height: 120)
                        .overlay {
                            Image(systemName: "hand.tap.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                        }
                }

                // Actions
                HStack(spacing: 32) {
                    Button("Reset") {
                        viewModel.reset()
                    }
                    .foregroundStyle(.secondary)

                    Button("Save") {
                        viewModel.saveSession(context: modelContext)
                    }
                    .disabled(viewModel.currentCount == 0)
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("Dhikr")
            .task {
                viewModel.loadPresets(context: modelContext)
            }
        }
    }
}
