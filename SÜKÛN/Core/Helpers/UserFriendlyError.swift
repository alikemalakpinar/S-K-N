import Foundation

/// Maps technical errors to user-friendly localized messages.
enum UserFriendlyError {

    static func message(from error: Error) -> String {
        let desc = error.localizedDescription.lowercased()

        // Location errors
        if error is LocationError {
            return L10n.Error.locationDenied
        }

        // SQLite / GRDB / Database errors
        if desc.contains("sqlite") || desc.contains("database") || desc.contains("grdb") {
            return L10n.Error.databaseFailed
        }

        // Network errors
        if desc.contains("network") || desc.contains("internet") || desc.contains("offline")
            || desc.contains("urlsession") || desc.contains("timed out") || desc.contains("not connected") {
            return L10n.Error.noInternet
        }

        // File not found
        if desc.contains("no such file") || desc.contains("not found") || desc.contains("does not exist") {
            return L10n.Error.notFound
        }

        // Prayer calculation
        if desc.contains("prayer") || desc.contains("calculation") {
            return L10n.Error.prayerCalcFailed
        }

        // Decoding / parsing
        if desc.contains("decod") || desc.contains("pars") || desc.contains("json") {
            return L10n.Error.decodingFailed
        }

        // Generic fallback
        return L10n.Error.genericError
    }
}
