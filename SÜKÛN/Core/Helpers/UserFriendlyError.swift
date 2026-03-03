import Foundation

/// Maps technical errors to user-friendly Turkish messages.
enum UserFriendlyError {

    static func message(from error: Error) -> String {
        let desc = error.localizedDescription.lowercased()

        // Location errors
        if error is LocationError {
            return "Konum erişimi sağlanamadı. Lütfen Ayarlar'dan konum iznini etkinleştirin."
        }

        // SQLite / GRDB / Database errors
        if desc.contains("sqlite") || desc.contains("database") || desc.contains("grdb") {
            return "Veritabanına erişilemedi. Lütfen uygulamayı yeniden başlatın."
        }

        // Network errors
        if desc.contains("network") || desc.contains("internet") || desc.contains("offline")
            || desc.contains("urlsession") || desc.contains("timed out") || desc.contains("not connected") {
            return "İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin."
        }

        // File not found
        if desc.contains("no such file") || desc.contains("not found") || desc.contains("does not exist") {
            return "İstenen veri bulunamadı."
        }

        // Prayer calculation
        if desc.contains("prayer") || desc.contains("calculation") {
            return "Namaz vakitleri hesaplanamadı. Lütfen konum ve ayarları kontrol edin."
        }

        // Decoding / parsing
        if desc.contains("decod") || desc.contains("pars") || desc.contains("json") {
            return "Veri okunamadı. Lütfen uygulamayı güncelleyin."
        }

        // Generic fallback
        return "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin."
    }
}
