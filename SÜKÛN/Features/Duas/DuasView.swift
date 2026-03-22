import SwiftUI

struct DuasView: View {
    @State private var viewModel: DuasViewModel
    @State private var appeared = false

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: DuasViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isStaticDBMissing {
                    SKNErrorState(
                        icon: "externaldrive.badge.exclamationmark",
                        message: L10n.Duas.dbMissing
                    )
                } else if let selected = viewModel.selectedCategory {
                    categoryDetailView(selected)
                } else if !viewModel.searchQuery.isEmpty {
                    searchResultsView
                } else {
                    categoryBrowseView
                }
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle(L10n.Duas.title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery, prompt: L10n.Duas.searchPrompt)
            .onChange(of: viewModel.searchQuery) {
                viewModel.search()
            }
            .onAppear {
                viewModel.loadCategories()
                withAnimation(DS.Motion.slowReveal) { appeared = true }
            }
        }
    }

    // MARK: - Category Browse

    private var categoryBrowseView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DS.Space.lg) {
                DSSectionHeader(L10n.Duas.categories, serif: true)
                    .padding(.horizontal, DS.Space.lg)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: DS.Space.md),
                        GridItem(.flexible(), spacing: DS.Space.md)
                    ],
                    spacing: DS.Space.md
                ) {
                    ForEach(Array(viewModel.categories.enumerated()), id: \.element) { index, category in
                        categoryCard(category, index: index)
                    }
                }
                .padding(.horizontal, DS.Space.lg)
            }
            .padding(.bottom, DS.Space.x4)
        }
    }

    private func categoryCard(_ category: String, index: Int) -> some View {
        Button {
            DS.Haptic.softTap()
            withAnimation(DS.Motion.standard) {
                viewModel.selectCategory(category)
            }
        } label: {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                Image(systemName: categoryIcon(for: category))
                    .font(DS.Typography.alongSans(size: 20, weight: "Medium"))
                    .foregroundStyle(DS.Color.accent)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                            .fill(DS.Color.accentSoft)
                    )

                Text(category)
                    .font(DS.Typography.listTitle)
                    .foregroundStyle(DS.Color.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DS.Space.lg)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(DS.Color.cardElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(DS.Color.hairline, lineWidth: 0.5)
            )
            .dsShadow(DS.Shadow.card)
        }
        .buttonStyle(.plain)
        .dsAppear(loaded: appeared, index: index)
    }

    // MARK: - Category Detail

    private func categoryDetailView(_ category: String) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DS.Space.lg) {
                // Back button header
                HStack {
                    Button {
                        DS.Haptic.softTap()
                        withAnimation(DS.Motion.standard) {
                            viewModel.clearCategory()
                        }
                    } label: {
                        HStack(spacing: DS.Space.xs) {
                            Image(systemName: "chevron.left")
                                .font(DS.Typography.alongSans(size: 13, weight: "SemiBold"))
                            Text(L10n.Duas.categories)
                                .font(DS.Typography.caption)
                        }
                        .foregroundStyle(DS.Color.accent)
                    }

                    Spacer()

                    Text("\(viewModel.categoryDuas.count)")
                        .font(DS.Typography.micro)
                        .foregroundStyle(DS.Color.textTertiary)
                        .padding(.horizontal, DS.Space.sm)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(DS.Color.accentSoft)
                        )
                }
                .padding(.horizontal, DS.Space.lg)

                DSSectionHeader(category, serif: true)
                    .padding(.horizontal, DS.Space.lg)

                if viewModel.isCategoryLoading {
                    DSSkeletonGroup(rows: 3)
                        .padding(.horizontal, DS.Space.lg)
                } else {
                    LazyVStack(spacing: DS.Space.lg) {
                        ForEach(viewModel.categoryDuas) { dua in
                            duaCard(dua)
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                }
            }
            .padding(.bottom, DS.Space.x4)
        }
    }

    // MARK: - Search Results

    private var searchResultsView: some View {
        Group {
            if viewModel.isSearching {
                DSSkeletonGroup(rows: 3)
                    .padding(.horizontal, DS.Space.lg)
            } else if viewModel.searchResults.isEmpty && viewModel.searchQuery.count >= 2 {
                SKNEmptyState(
                    icon: "magnifyingglass",
                    title: L10n.Duas.noResults,
                    message: L10n.Duas.noResultsFor(viewModel.searchQuery)
                )
            } else if viewModel.searchResults.isEmpty {
                Color.clear
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
    }

    // MARK: - Dua Card

    private func duaCard(_ dua: DuaDTO) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text(dua.title)
                .font(DS.Typography.displayBody)
                .foregroundStyle(DS.Color.textPrimary)

            Text(dua.textArabic)
                .font(DS.Typography.arabicVerse)
                .multilineTextAlignment(.trailing)
                .lineSpacing(DS.Typography.LineSpacing.arabic)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(DS.Color.textPrimary)
                .padding(.vertical, DS.Space.sm)

            Text(dua.textTranslation)
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Color.textSecondary)
                .lineSpacing(4)

            Hairline()

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
        }
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(DS.Color.cardElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(DS.Color.hairline, lineWidth: 0.5)
        )
        .dsShadow(DS.Shadow.card)
    }

    // MARK: - Helpers

    private func categoryIcon(for category: String) -> String {
        let lower = category.lowercased()
        if lower.contains("sabah") || lower.contains("akşam") { return "sun.horizon.fill" }
        if lower.contains("yemek") || lower.contains("iftar") { return "fork.knife" }
        if lower.contains("namaz") || lower.contains("salat") { return "hands.and.sparkles.fill" }
        if lower.contains("yolculuk") || lower.contains("sefer") { return "airplane" }
        if lower.contains("uyku") || lower.contains("gece") { return "moon.stars.fill" }
        if lower.contains("şifa") || lower.contains("hasta") { return "heart.fill" }
        if lower.contains("koruma") || lower.contains("sığınma") { return "shield.fill" }
        if lower.contains("tövbe") || lower.contains("istiğfar") { return "arrow.uturn.backward.circle.fill" }
        if lower.contains("şükür") { return "sparkles" }
        if lower.contains("rahmet") || lower.contains("bereket") { return "leaf.fill" }
        return "text.book.closed.fill"
    }
}
