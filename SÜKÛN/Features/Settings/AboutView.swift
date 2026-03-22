import SwiftUI

struct AboutView: View {
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DS.Space.x2) {
                // Quran Text
                DSCard {
                    VStack(alignment: .leading, spacing: DS.Space.md) {
                        DSSectionHeader(L10n.About.quranTextTitle, serif: true)
                        Text(L10n.About.quranDataInfo)
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                            .lineSpacing(4)
                    }
                }
                .dsAppear(loaded: appeared, index: 0)

                // Translation
                DSCard {
                    VStack(alignment: .leading, spacing: DS.Space.md) {
                        DSSectionHeader(L10n.About.translationTitle, serif: true)
                        Text(L10n.About.translationInfo)
                            .font(DS.Typography.caption)
                            .foregroundStyle(DS.Color.textSecondary)
                            .lineSpacing(4)
                    }
                }
                .dsAppear(loaded: appeared, index: 1)

                // Open Source Libraries
                DSCard {
                    VStack(alignment: .leading, spacing: DS.Space.md) {
                        DSSectionHeader(L10n.About.openSourceTitle, serif: true)

                        if let grdbURL = URL(string: "https://github.com/groue/GRDB.swift") {
                            Link(destination: grdbURL) {
                                libraryRow(
                                    name: "GRDB.swift",
                                    detail: L10n.About.grdbDetail
                                )
                            }
                        }

                        Hairline()

                        if let adhanURL = URL(string: "https://github.com/batoulapps/adhan-swift") {
                            Link(destination: adhanURL) {
                                libraryRow(
                                    name: "Adhan-swift",
                                    detail: L10n.About.adhanDetail
                                )
                            }
                        }
                    }
                }
                .dsAppear(loaded: appeared, index: 2)
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.bottom, DS.Space.x4)
        }
        .background(DS.Color.backgroundPrimary)
        .tint(DS.Color.accent)
        .navigationTitle(L10n.About.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(DS.Motion.slowReveal) { appeared = true }
        }
    }

    private func libraryRow(name: String, detail: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(DS.Typography.body)
                    .foregroundStyle(DS.Color.textPrimary)
                Text(detail)
                    .font(DS.Typography.captionSm)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(DS.Typography.alongSans(size: 11, weight: "Medium"))
                .foregroundStyle(DS.Color.accent)
        }
        .padding(.vertical, DS.Space.xs)
    }
}
