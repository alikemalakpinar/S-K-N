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
                        "Database Not Found",
                        systemImage: "externaldrive.badge.exclamationmark",
                        description: Text("The duas database is not bundled. See README for setup.")
                    )
                } else if viewModel.searchResults.isEmpty && viewModel.searchQuery.isEmpty {
                    ContentUnavailableView("Search Duas", systemImage: "text.magnifyingglass", description: Text("Type a keyword to search duas."))
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
            .navigationTitle("Duas")
            .searchable(text: $viewModel.searchQuery, prompt: "Search duas...")
            .onChange(of: viewModel.searchQuery) {
                viewModel.search()
            }
        }
    }
}
