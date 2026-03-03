import SwiftUI

struct MushafReaderView: View {
    @Bindable var viewModel: QuranViewModel
    let container: DependencyContainer

    @State private var showPagePicker = false
    @State private var showControls = true

    var body: some View {
        ZStack {
            // Full-bleed page reader
            TabView(selection: $viewModel.currentPage) {
                ForEach(1...viewModel.totalPages, id: \.self) { page in
                    MushafPageView(pageNumber: page, container: container)
                        .tag(page)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Floating bottom bar
            VStack {
                Spacer()
                bottomBar
            }
        }
        .background(DS.Color.backgroundPrimary)
        .sheet(isPresented: $showPagePicker) {
            PagePickerSheet(
                viewModel: viewModel,
                isPresented: $showPagePicker
            )
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        Button {
            showPagePicker = true
        } label: {
            HStack(spacing: DS.Space.md) {
                // Juz indicator
                Text("Cüz \(viewModel.currentJuzNumber)")
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.accent)
                    .padding(.horizontal, DS.Space.sm)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(DS.Color.accentSoft)
                    )

                // Page number
                HStack(spacing: 4) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 10, weight: .medium))
                    Text("\(viewModel.currentPage)")
                        .font(DS.Typography.pageNumber)
                }
                .foregroundStyle(DS.Color.textSecondary)

                // Divider dot
                Circle()
                    .fill(DS.Color.textSecondary.opacity(0.3))
                    .frame(width: 3, height: 3)

                // Total pages
                Text("/ \(viewModel.totalPages)")
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textSecondary.opacity(0.6))
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.sm)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
            )
        }
        .padding(.bottom, DS.Space.sm)
    }
}

// MARK: - Page Picker Sheet

private struct PagePickerSheet: View {
    @Bindable var viewModel: QuranViewModel
    @Binding var isPresented: Bool
    @State private var searchText = ""

    private var filteredSurahs: [SurahDTO] {
        if searchText.isEmpty { return viewModel.surahs }
        let q = searchText.lowercased()
        return viewModel.surahs.filter {
            $0.nameTurkish.lowercased().contains(q) ||
            $0.nameArabic.contains(q) ||
            $0.nameEnglish.lowercased().contains(q) ||
            "\($0.id)" == q
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Page slider section
                pageSliderSection
                    .padding(.top, DS.Space.lg)

                Hairline()
                    .padding(.vertical, DS.Space.sm)

                // Surah list
                surahListSection
            }
            .background(DS.Color.backgroundPrimary)
            .navigationTitle("Sayfa Seç")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Sure ara...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") {
                        isPresented = false
                    }
                    .foregroundStyle(DS.Color.accent)
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var pageSliderSection: some View {
        VStack(spacing: DS.Space.md) {
            // Large page number
            HStack(alignment: .firstTextBaseline, spacing: DS.Space.xs) {
                Text("\(viewModel.currentPage)")
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .foregroundStyle(DS.Color.accent)
                Text("/ \(viewModel.totalPages)")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(DS.Color.textSecondary)
            }

            // Juz info
            Text("Cüz \(viewModel.currentJuzNumber)")
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Color.textSecondary)

            // Slider
            Slider(
                value: Binding(
                    get: { Double(viewModel.currentPage) },
                    set: { viewModel.currentPage = Int($0) }
                ),
                in: 1...Double(viewModel.totalPages),
                step: 1
            )
            .tint(DS.Color.accent)
            .padding(.horizontal, DS.Space.lg)
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.bottom, DS.Space.md)
    }

    private var surahListSection: some View {
        List(filteredSurahs) { surah in
            Button {
                Task {
                    let page = await viewModel.jumpToSurah(surah.id)
                    viewModel.currentPage = page
                    isPresented = false
                }
            } label: {
                HStack(spacing: DS.Space.md) {
                    // Surah number in ornament
                    ZStack {
                        RotatedStarSmall()
                            .fill(DS.Color.accentSoft)
                            .frame(width: 32, height: 32)
                        RotatedStarSmall()
                            .stroke(DS.Color.accent.opacity(0.3), lineWidth: 0.5)
                            .frame(width: 32, height: 32)
                        Text("\(surah.id)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(DS.Color.accent)
                    }

                    // Turkish name + info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(surah.nameTurkish)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(DS.Color.textPrimary)
                        Text("\(surah.verseCount) ayet \u{2022} \(surah.revelationType == "Meccan" ? "Mekki" : "Medeni")")
                            .font(DS.Typography.captionSm)
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    Spacer()

                    // Arabic name
                    Text(surah.nameArabic)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(DS.Color.textPrimary)
                }
                .padding(.vertical, DS.Space.xs)
            }
            .listRowBackground(DS.Color.backgroundPrimary)
            .listRowSeparator(.hidden)
            .overlay(alignment: .bottom) { Hairline() }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Small Rotated Star (for page picker)

private struct RotatedStarSmall: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.65
        let points = 8
        var path = Path()
        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
