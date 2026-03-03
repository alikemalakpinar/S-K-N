import Foundation

protocol WidgetDataServiceProtocol: Sendable {
    func writeNextPrayerData(name: String, time: Date) throws
    func readNextPrayerData() -> NextPrayerWidgetData?
}

struct NextPrayerWidgetData: Codable, Sendable {
    let prayerName: String
    let prayerTime: Date
    let updatedAt: Date
}

final class WidgetDataService: WidgetDataServiceProtocol, Sendable {
    private let fileURL: URL

    init() {
        // Use shared app group container if available, otherwise fallback to app support
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.AliKemalAkpinar.SU-KU-N") {
            fileURL = groupURL.appendingPathComponent("next_prayer.json")
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dir = appSupport.appendingPathComponent("Sukun", isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            fileURL = dir.appendingPathComponent("next_prayer.json")
        }
    }

    func writeNextPrayerData(name: String, time: Date) throws {
        let data = NextPrayerWidgetData(prayerName: name, prayerTime: time, updatedAt: Date())
        let encoded = try JSONEncoder().encode(data)
        try encoded.write(to: fileURL, options: .atomic)
    }

    func readNextPrayerData() -> NextPrayerWidgetData? {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(NextPrayerWidgetData.self, from: data) else {
            return nil
        }
        return decoded
    }
}
