import Foundation
import SwiftData

@Observable
final class KazaViewModel {
    var kazaPrayer: KazaPrayer?
    var errorMessage: String?

    func load(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<KazaPrayer>(
                predicate: #Predicate { $0.id == "default" }
            )
            if let existing = try context.fetch(descriptor).first {
                kazaPrayer = existing
            } else {
                let newRecord = KazaPrayer()
                context.insert(newRecord)
                try context.save()
                kazaPrayer = newRecord
            }
        } catch {
            errorMessage = "Kaza verileri yüklenemedi."
        }
    }

    func increment(_ prayer: KazaPrayerType, context: ModelContext) {
        guard let kaza = kazaPrayer else { return }
        switch prayer {
        case .fajr:    kaza.fajrCount += 1
        case .dhuhr:   kaza.dhuhrCount += 1
        case .asr:     kaza.asrCount += 1
        case .maghrib: kaza.maghribCount += 1
        case .isha:    kaza.ishaCount += 1
        case .vitr:    kaza.vitrCount += 1
        }
        kaza.updatedAt = Date()
        try? context.save()
        DS.Haptic.dhikrTap()
    }

    func decrement(_ prayer: KazaPrayerType, context: ModelContext) {
        guard let kaza = kazaPrayer else { return }
        switch prayer {
        case .fajr:    kaza.fajrCount = max(0, kaza.fajrCount - 1)
        case .dhuhr:   kaza.dhuhrCount = max(0, kaza.dhuhrCount - 1)
        case .asr:     kaza.asrCount = max(0, kaza.asrCount - 1)
        case .maghrib: kaza.maghribCount = max(0, kaza.maghribCount - 1)
        case .isha:    kaza.ishaCount = max(0, kaza.ishaCount - 1)
        case .vitr:    kaza.vitrCount = max(0, kaza.vitrCount - 1)
        }
        kaza.updatedAt = Date()
        try? context.save()
    }

    func count(for prayer: KazaPrayerType) -> Int {
        guard let kaza = kazaPrayer else { return 0 }
        switch prayer {
        case .fajr:    return kaza.fajrCount
        case .dhuhr:   return kaza.dhuhrCount
        case .asr:     return kaza.asrCount
        case .maghrib: return kaza.maghribCount
        case .isha:    return kaza.ishaCount
        case .vitr:    return kaza.vitrCount
        }
    }
}

enum KazaPrayerType: String, CaseIterable, Identifiable {
    case fajr = "Sabah"
    case dhuhr = "Öğle"
    case asr = "İkindi"
    case maghrib = "Akşam"
    case isha = "Yatsı"
    case vitr = "Vitir"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fajr:    return "sunrise.fill"
        case .dhuhr:   return "sun.max.fill"
        case .asr:     return "sun.haze.fill"
        case .maghrib: return "sunset.fill"
        case .isha:    return "moon.stars.fill"
        case .vitr:    return "moon.fill"
        }
    }
}
