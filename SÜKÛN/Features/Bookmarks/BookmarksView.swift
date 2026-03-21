import SwiftUI
import SwiftData

struct BookmarksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bookmark.createdAt, order: .reverse) private var bookmarks: [Bookmark]
    @State private var appeared = false
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    var body: some View {
        Group {
            if bookmarks.isEmpty {
                SKNEmptyState(
                    icon: "bookmark",
                    title: L10n.Bookmarks.emptyTitle,
                    message: L10n.Bookmarks.emptyMessage
                )
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: DS.Space.md) {
                        ForEach(Array(bookmarks.enumerated()), id: \.element.persistentModelID) { index, bookmark in
                            bookmarkRow(bookmark, index: index)
                        }
                    }
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.vertical, DS.Space.md)
                    .padding(.bottom, DS.Space.x4)
                }
            }
        }
        .background(DS.Color.backgroundPrimary)
        .navigationTitle(L10n.Bookmarks.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(DS.Motion.slowReveal) { appeared = true }
        }
    }

    private func bookmarkRow(_ bookmark: Bookmark, index: Int) -> some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: iconFor(bookmark.type))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(colorFor(bookmark.type))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                        .fill(colorFor(bookmark.type).opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(titleFor(bookmark))
                    .font(DS.Typography.listTitle)
                    .foregroundStyle(DS.Color.textPrimary)
                    .lineLimit(1)

                Text(bookmark.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textTertiary)
            }

            Spacer(minLength: 0)

            if !bookmark.note.isEmpty {
                Image(systemName: "note.text")
                    .font(.system(size: 11))
                    .foregroundStyle(DS.Color.textTertiary)
            }
        }
        .padding(DS.Space.md)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(DS.Color.cardElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(DS.Color.hairline, lineWidth: 0.5)
        )
        .dsAppear(loaded: appeared, index: index)
    }

    // MARK: - Helpers

    private func iconFor(_ type: BookmarkType) -> String {
        switch type {
        case .verse: "text.book.closed.fill"
        case .dua: "hands.sparkles.fill"
        case .page: "doc.text.fill"
        }
    }

    private func colorFor(_ type: BookmarkType) -> Color {
        switch type {
        case .verse: DS.Color.accent
        case .dua: DS.Color.success
        case .page: DS.Color.warning
        }
    }

    private func titleFor(_ bookmark: Bookmark) -> String {
        switch bookmark.type {
        case .verse:
            return "\(L10n.Bookmarks.verse) \(bookmark.refId)"
        case .dua:
            return "\(L10n.Bookmarks.dua) \(bookmark.refId)"
        case .page:
            return "\(L10n.Bookmarks.page) \(bookmark.refId)"
        }
    }
}

// MARK: - Preview

#Preview("Bookmarks") {
    NavigationStack {
        DSPreview { c in BookmarksView(container: c) }
    }
}
