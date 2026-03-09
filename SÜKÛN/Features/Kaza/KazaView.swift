import SwiftUI
import SwiftData

struct KazaView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = KazaViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Total counter hero
                    totalHero
                        .padding(.top, DS.Space.x2)
                        .padding(.horizontal, DS.Space.lg)

                    // Prayer counters
                    LazyVStack(spacing: DS.Space.md) {
                        ForEach(KazaPrayerType.allCases) { prayer in
                            kazaRow(prayer)
                        }
                    }
                    .padding(.top, DS.Space.x2)
                    .padding(.horizontal, DS.Space.lg)

                    // Info text
                    infoSection
                        .padding(.top, DS.Space.x3)
                        .padding(.horizontal, DS.Space.lg)

                    Spacer(minLength: DS.Space.x4)
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Kaza Takibi")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.load(context: modelContext)
            }
        }
    }

    // MARK: - Total Hero

    private var totalHero: some View {
        VStack(spacing: DS.Space.sm) {
            Text("TOPLAM KAZA")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(3)

            Text("\(viewModel.kazaPrayer?.totalCount ?? 0)")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(DS.Color.textPrimary)
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.2), value: viewModel.kazaPrayer?.totalCount)

            Text("namaz")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(DS.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.x2)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        )
    }

    // MARK: - Kaza Row

    private func kazaRow(_ prayer: KazaPrayerType) -> some View {
        HStack(spacing: DS.Space.lg) {
            // Prayer icon + name
            HStack(spacing: DS.Space.md) {
                Image(systemName: prayer.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(DS.Color.accent)
                    .frame(width: 24)

                Text(prayer.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DS.Color.textPrimary)
            }

            Spacer()

            // Counter controls
            HStack(spacing: DS.Space.lg) {
                // Decrement button
                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        viewModel.decrement(prayer, context: modelContext)
                    }
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
                .disabled(viewModel.count(for: prayer) <= 0)
                .opacity(viewModel.count(for: prayer) <= 0 ? 0.3 : 1)

                // Count
                Text("\(viewModel.count(for: prayer))")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Color.textPrimary)
                    .frame(minWidth: 50)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.15), value: viewModel.count(for: prayer))

                // Increment button
                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        viewModel.increment(prayer, context: modelContext)
                    }
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
            RoundedRectangle(cornerRadius: 16)
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
            RoundedRectangle(cornerRadius: 12)
                .fill(DS.Color.accentSoft)
        )
    }
}
