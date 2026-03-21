import SwiftUI

struct RehberView: View {
    @State private var viewModel: RehberViewModel
    @State private var appeared = false

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: RehberViewModel(container: container))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Space.lg) {
                moduleCard(
                    title: "Harfler ve Sesler",
                    subtitle: "Arap alfabesinin temel harfleri ve sesleri.",
                    icon: "character.textbox",
                    destination: ElifbaView(viewModel: viewModel)
                )
                .dsAppear(loaded: appeared, index: 0)

                moduleCard(
                    title: "Arınma Adımları",
                    subtitle: "Abdest alınışı, adım adım.",
                    icon: "drop.fill",
                    destination: AbdestView(viewModel: viewModel)
                )
                .dsAppear(loaded: appeared, index: 1)

                moduleCard(
                    title: "Namazın Anatomisi",
                    subtitle: "Namaz kılınışı, duruş ve okunuşlarıyla.",
                    icon: "figure.mind.and.body",
                    destination: NamazView(viewModel: viewModel)
                )
                .dsAppear(loaded: appeared, index: 2)
            }
            .padding(DS.Space.lg)
        }
        .background(DS.Color.backgroundPrimary)
        .task {
            viewModel.loadAll()
            withAnimation(DS.Motion.slowReveal) {
                appeared = true
            }
        }
    }

    private func moduleCard<D: View>(title: String, subtitle: String, icon: String, destination: D) -> some View {
        NavigationLink {
            destination
        } label: {
            DSCard {
                HStack(spacing: DS.Space.lg) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(DS.Color.accent)
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        Text(title)
                            .font(DS.Typography.displayBody)
                            .foregroundStyle(DS.Color.textPrimary)
                        Text(subtitle)
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(DS.Typography.caption)
                        .foregroundStyle(DS.Color.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
