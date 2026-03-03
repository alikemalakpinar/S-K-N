import Foundation
import Adhan
import CoreLocation

final class DefaultPrayerTimesRepository: PrayerTimesRepository {

    func prayerTimes(for date: Date, latitude: Double, longitude: Double, method: String, asrMethod: String) async throws -> PrayerDay {
        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        var params = Self.calculationParameters(for: method)
        params.madhab = asrMethod == "hanafi" ? .hanafi : .shafi

        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let times = PrayerTimes(coordinates: coordinates, date: components, calculationParameters: params) else {
            throw PrayerTimeError.calculationFailed
        }

        return PrayerDay(
            date: date,
            fajr: times.fajr,
            sunrise: times.sunrise,
            dhuhr: times.dhuhr,
            asr: times.asr,
            maghrib: times.maghrib,
            isha: times.isha
        )
    }

    func prayerTimes(from startDate: Date, days: Int, latitude: Double, longitude: Double, method: String, asrMethod: String) async throws -> [PrayerDay] {
        var results: [PrayerDay] = []
        let calendar = Calendar.current

        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }
            let day = try await prayerTimes(for: date, latitude: latitude, longitude: longitude, method: method, asrMethod: asrMethod)
            results.append(day)
        }

        return results
    }

    // MARK: - Method Mapping

    static func calculationParameters(for method: String) -> CalculationParameters {
        switch method {
        case "NorthAmerica":
            return CalculationMethod.northAmerica.params
        case "MuslimWorldLeague":
            return CalculationMethod.muslimWorldLeague.params
        case "Egyptian":
            return CalculationMethod.egyptian.params
        case "Karachi":
            return CalculationMethod.karachi.params
        case "UmmAlQura":
            return CalculationMethod.ummAlQura.params
        case "Dubai":
            return CalculationMethod.dubai.params
        case "Kuwait":
            return CalculationMethod.kuwait.params
        case "Qatar":
            return CalculationMethod.qatar.params
        case "Singapore":
            return CalculationMethod.singapore.params
        case "Turkey":
            return CalculationMethod.turkey.params
        case "Tehran":
            return CalculationMethod.tehran.params
        default:
            return CalculationMethod.muslimWorldLeague.params
        }
    }
}

enum PrayerTimeError: LocalizedError {
    case calculationFailed

    var errorDescription: String? {
        switch self {
        case .calculationFailed:
            return "Failed to calculate prayer times for the given date and location."
        }
    }
}
