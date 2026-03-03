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
                    List(viewModel.searchResults) { dua in
                        VStack(alignment: .leading, spacing: DS.Space.sm) {
                            Text(dua.title)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(DS.Color.textPrimary)
                            Text(dua.textArabic)
                                .font(.system(size: 20, weight: .regular))
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundStyle(DS.Color.textPrimary)
                            Text(dua.textTranslation)
                                .font(DS.Typography.body)
                                .foregroundStyle(DS.Color.textSecondary)
                            Hairline()
                            HStack {
                                Text(dua.category)
                                Spacer()
                                Text(dua.source)
                            }
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.textSecondary)
                        }
                        .padding(.vertical, DS.Space.xs)
                        .listRowBackground(DS.Color.backgroundPrimary)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(DS.Color.backgroundPrimary)
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Dualar")
            .searchable(text: $viewModel.searchQuery, prompt: "Dua ara...")
            .onChange(of: viewModel.searchQuery) {
                viewModel.search()
            }
        }
    }
}
