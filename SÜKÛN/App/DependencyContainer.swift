import Foundation
import SwiftData

@Observable
final class DependencyContainer {
    // MARK: - Static DB

    private(set) var staticDBClient: StaticDBClientProtocol?
    private(set) var staticDBError: StaticDBError?

    // MARK: - Repositories

    private(set) var quranRepository: (any QuranRepository)?
    private(set) var duaRepository: (any DuaRepository)?
    let prayerTimesRepository: any PrayerTimesRepository = DefaultPrayerTimesRepository()
    let userActivityRepository: any UserActivityRepository = DefaultUserActivityRepository()

    // MARK: - Services

    let locationService: any LocationServiceProtocol = LocationService()
    let prayerTimeService: any PrayerTimeServiceProtocol
    let notificationScheduler: any NotificationSchedulerProtocol = NotificationScheduler()
    let widgetDataService: any WidgetDataServiceProtocol = WidgetDataService()

    // MARK: - SwiftData

    let modelContainer: ModelContainer

    init() {
        // Set up SwiftData container
        let schema = Schema([
            UserSetting.self,
            PrayerLog.self,
            ReadingLog.self,
            CounterPreset.self,
            CounterSession.self,
            FavoriteItem.self,
            Bookmark.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }

        // Prayer time service depends on repository
        prayerTimeService = PrayerTimeService(repository: prayerTimesRepository)

        // Attempt to open static DB (graceful failure if missing)
        do {
            let client = try StaticDBClient()
            staticDBClient = client
            quranRepository = DefaultQuranRepository(dbClient: client)
            duaRepository = DefaultDuaRepository(dbClient: client)
        } catch let error as StaticDBError {
            staticDBError = error
        } catch {
            staticDBError = .databaseCorrupted(underlying: error)
        }
    }

    // MARK: - Convenience

    var isStaticDBAvailable: Bool {
        staticDBClient != nil
    }
}
