import SwiftUI

struct DuasView: View {
    @State private var viewModel: DuasViewModel

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: DuasViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isStaticDBMissing {
                    ContentUnavailableView(
                        "Veritabanı Bulunamadı",
                        systemImage: "externaldrive.badge.exclamationmark",
                        description: Text("Dua veritabanı uygulamada bulunamadı.")
                    )
                } else if viewModel.searchResults.isEmpty && viewModel.searchQuery.isEmpty {
                    ContentUnavailableView("Dua Ara", systemImage: "text.magnifyingglass", description: Text("Aramak için bir kelime yazın."))
                } else if viewModel.isSearching {
                    ProgressView()
                        .tint(DS.Color.accent)
                } else if viewModel.searchResults.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchQuery)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: DS.Space.lg) {
                            ForEach(viewModel.searchResults) { dua in
                                duaCard(dua)
                            }
                        }
                        .padding(.horizontal, DS.Space.lg)
                        .padding(.bottom, DS.Space.x4)
                    }
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Dualar")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery, prompt: "Dua ara...")
            .onChange(of: viewModel.searchQuery) {
                viewModel.search()
            }
        }
    }

    private func duaCard(_ dua: DuaDTO) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            // Title
            Text(dua.title)
                .font(DS.Typography.headline)
                .foregroundStyle(DS.Color.textPrimary)

            // Arabic text
            Text(dua.textArabic)
                .font(DS.Typography.arabicVerse)
                .multilineTextAlignment(.trailing)
                .lineSpacing(12)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(DS.Color.textPrimary)
                .padding(.vertical, DS.Space.sm)

            // Translation
            Text(dua.textTranslation)
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Color.textSecondary)
                .lineSpacing(4)

            // Metadata
            HStack {
                Text(dua.category)
                    .font(DS.Typography.micro)
                    .textCase(.uppercase)
                    .tracking(1)
                Spacer()
                Text(dua.source)
                    .font(DS.Typography.captionSm)
            }
            .foregroundStyle(DS.Color.textTertiary)
            .padding(.top, DS.Space.xs)
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        )
    }
}
