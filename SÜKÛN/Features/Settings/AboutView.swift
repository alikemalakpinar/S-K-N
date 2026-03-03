import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                Text("Quran text is provided by the Tanzil project (tanzil.net). The original Arabic Uthmani text has not been modified. Redistribution complies with Tanzil's terms of use.")
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            } header: {
                Text("Quran Text")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .listRowBackground(DS.Color.backgroundSecondary)

            Section {
                Text("Turkish translation source will be finalized; only public-domain or compatible-licensed sources will be used.")
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            } header: {
                Text("Translation")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .listRowBackground(DS.Color.backgroundSecondary)

            Section {
                Link(destination: URL(string: "https://github.com/groue/GRDB.swift")!) {
                    row(name: "GRDB.swift", detail: "SQLite toolkit for Swift — MIT License")
                }
                Link(destination: URL(string: "https://github.com/batoulapps/adhan-swift")!) {
                    row(name: "Adhan-swift", detail: "Prayer time calculation — MIT License")
                }
            } header: {
                Text("Open Source Libraries")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .listRowBackground(DS.Color.backgroundSecondary)
        }
        .scrollContentBackground(.hidden)
        .background(DS.Color.backgroundPrimary)
        .tint(DS.Color.accent)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(name: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(DS.Typography.body)
                .foregroundStyle(DS.Color.textPrimary)
            Text(detail)
                .font(DS.Typography.captionSm)
                .foregroundStyle(DS.Color.textSecondary)
        }
    }
}
