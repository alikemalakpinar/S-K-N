import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                Text("Kur'an-ı Kerim metni Al Quran Cloud API aracılığıyla sağlanmaktadır. Orijinal Arapça Osmanlı hattı metni değiştirilmemiştir.")
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            } header: {
                Text("Kur'an Metni")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .listRowBackground(DS.Color.cardElevated)

            Section {
                Text("Türkçe meal: Diyanet İşleri Başkanlığı çevirisi kullanılmaktadır.")
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            } header: {
                Text("Meal")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .listRowBackground(DS.Color.cardElevated)

            Section {
                if let grdbURL = URL(string: "https://github.com/groue/GRDB.swift") {
                    Link(destination: grdbURL) {
                        row(name: "GRDB.swift", detail: "Swift için SQLite araç seti — MIT Lisansı")
                    }
                }
                if let adhanURL = URL(string: "https://github.com/batoulapps/adhan-swift") {
                    Link(destination: adhanURL) {
                        row(name: "Adhan-swift", detail: "Namaz vakti hesaplama — MIT Lisansı")
                    }
                }
            } header: {
                Text("Açık Kaynak Kütüphaneler")
                    .font(DS.Typography.sectionHead)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            .listRowBackground(DS.Color.cardElevated)
        }
        .scrollContentBackground(.hidden)
        .background(DS.Color.backgroundPrimary)
        .tint(DS.Color.accent)
        .navigationTitle("Hakkında")
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
