import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section("Quran Text") {
                Text("Quran text is provided by the Tanzil project (tanzil.net). The original Arabic Uthmani text has not been modified. Redistribution complies with Tanzil's terms of use.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Translation") {
                Text("Turkish translation source will be finalized; only public-domain or compatible-licensed sources will be used.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Open Source Libraries") {
                Link(destination: URL(string: "https://github.com/groue/GRDB.swift")!) {
                    row(name: "GRDB.swift", detail: "SQLite toolkit for Swift — MIT License")
                }
                Link(destination: URL(string: "https://github.com/batoulapps/adhan-swift")!) {
                    row(name: "Adhan-swift", detail: "Prayer time calculation — MIT License")
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(name: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .foregroundStyle(.primary)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
