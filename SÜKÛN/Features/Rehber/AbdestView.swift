import SwiftUI

struct AbdestView: View {
    let viewModel: RehberViewModel

    var body: some View {
        Group {
            if let abdest = viewModel.abdest {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(abdest.steps) { step in
                            timelineRow(step: step, isLast: step.order == abdest.steps.count)
                        }
                    }
                    .padding(DS.Space.lg)
                }
            } else {
                SKNErrorState(
                    icon: "doc.text",
                    message: "Abdest verileri yüklenemedi."
                )
            }
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle("Arınma Adımları")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func timelineRow(step: AbdestStep, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: DS.Space.lg) {
            // Timeline spine
            VStack(spacing: 0) {
                Circle()
                    .fill(DS.Color.accent)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)

                if !isLast {
                    Rectangle()
                        .fill(DS.Color.accent.opacity(0.3))
                        .frame(width: 1)
                }
            }
            .frame(width: 8)

            // Content
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                HStack(spacing: DS.Space.sm) {
                    Image(systemName: step.iconName)
                        .font(.system(size: 16, weight: .ultraLight))
                        .foregroundStyle(DS.Color.accent)
                        .frame(width: 20)

                    Text(step.title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(DS.Color.textPrimary)
                }

                Text(step.text)
                    .font(DS.Typography.body)
                    .foregroundStyle(DS.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, DS.Space.xl)
        }
    }
}
