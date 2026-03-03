import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section("Attribution") {
                Text("Quran text provided by Tanzil.net. Additional content attributions will be listed here as sources are integrated.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Open Source") {
                Link(destination: URL(string: "https://github.com/groue/GRDB.swift")!) {
                    row(name: "GRDB.swift", detail: "SQLite toolkit for Swift")
                }
                Link(destination: URL(string: "https://github.com/batoulapps/adhan-swift")!) {
                    row(name: "Adhan-swift", detail: "Prayer time calculation library")
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
