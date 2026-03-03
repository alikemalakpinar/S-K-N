import SwiftUI

struct MushafReaderView: View {
    @Bindable var viewModel: QuranViewModel
    let container: DependencyContainer

    @State private var showPagePicker = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.currentPage) {
                ForEach(1...viewModel.totalPages, id: \.self) { page in
                    MushafPageView(pageNumber: page, container: container)
                        .tag(page)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Bottom bar: page info + surah name
            pageInfoBar
        }
        .background(DS.Color.backgroundPrimary)
        .sheet(isPresented: $showPagePicker) {
            pagePickerSheet
        }
    }

    // MARK: - Page Info Bar

    private var pageInfoBar: some View {
        Button {
            showPagePicker = true
        } label: {
            HStack(spacing: DS.Space.md) {
                Image(systemName: "book.pages")
                    .font(.system(size: 12))
                Text("Sayfa \(viewModel.currentPage) / \(viewModel.totalPages)")
                    .font(DS.Typography.captionSm)
            }
            .foregroundStyle(DS.Color.textSecondary)
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.sm)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.bottom, DS.Space.sm)
    }

    // MARK: - Page Picker Sheet

    private var pagePickerSheet: some View {
        NavigationStack {
            VStack(spacing: DS.Space.xl) {
                // Page slider
                VStack(spacing: DS.Space.sm) {
                    Text("Sayfa \(viewModel.currentPage)")
                        .font(DS.Typography.sectionHead)
                        .foregroundStyle(DS.Color.accent)

                    Slider(
                        value: Binding(
                            get: { Double(viewModel.currentPage) },
                            set: { viewModel.currentPage = Int($0) }
                        ),
                        in: 1...Double(viewModel.totalPages),
                        step: 1
                    )
                    .tint(DS.Color.accent)
                }
                .padding(.horizontal, DS.Space.lg)

                Hairline()

                // Surah list for quick jump
                Text("Sureye Git")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DS.Space.lg)

                List(viewModel.surahs) { surah in
                    Button {
                        Task {
                            let page = await viewModel.jumpToSurah(surah.id)
                            viewModel.currentPage = page
                            showPagePicker = false
                        }
                    } label: {
                        HStack {
                            Text("\(surah.id)")
                                .font(DS.Typography.captionSm)
                                .foregroundStyle(DS.Color.textSecondary)
                                .frame(width: 28, alignment: .trailing)
                            Text(surah.nameTurkish)
                                .font(DS.Typography.body)
                                .foregroundStyle(DS.Color.textPrimary)
                            Spacer()
                            Text(surah.nameArabic)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(DS.Color.textPrimary)
                        }
                    }
                    .listRowBackground(DS.Color.backgroundSecondary)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .padding(.top, DS.Space.lg)
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Sayfa Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") {
                        showPagePicker = false
                    }
                    .foregroundStyle(DS.Color.accent)
                }
            }
        }
        .presentationDetents([.large])
    }
}
