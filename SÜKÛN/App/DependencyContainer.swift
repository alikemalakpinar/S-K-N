import Foundation
import SwiftData

@Observable
final class DependencyContainer {
    // MARK: - Static DB

    let staticDBClient: StaticDBClientProtocol
    private(set) var staticDBError: StaticDBError?

    // MARK: - Repositories

    let quranRepository: any QuranRepository
    let duaRepository: any DuaRepository
    let prayerTimesRepository: any PrayerTimesRepository = DefaultPrayerTimesRepository()
    let userActivityRepository: any UserActivityRepository = DefaultUserActivityRepository()

    // MARK: - Static Content

    let rehberLoader: any RehberLoaderProtocol = RehberLoader()

    // MARK: - Services

    let locationService: any LocationServiceProtocol = LocationService()
    let prayerTimeService: any PrayerTimeServiceProtocol
    let notificationScheduler: any NotificationSchedulerProtocol = NotificationScheduler()
    let widgetDataService: any WidgetDataServiceProtocol = WidgetDataService()
    let liveActivityManager: any LiveActivityManagerProtocol = LiveActivityManager()

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
            LastReadPosition.self,
            PageReadLog.self,
            KazaPrayer.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }

        // Prayer time service depends on repository
        prayerTimeService = PrayerTimeService(repository: prayerTimesRepository)

        // Attempt to open static DB; fall back to noop if missing
        var client: StaticDBClientProtocol
        do {
            client = try StaticDBClient()
        } catch let error as StaticDBError {
            staticDBError = error
            client = NoopStaticDBClient()
        } catch {
            staticDBError = .databaseCorrupted(underlying: error)
            client = NoopStaticDBClient()
        }
        staticDBClient = client
        quranRepository = DefaultQuranRepository(dbClient: client)
        duaRepository = DefaultDuaRepository(dbClient: client)
    }

    // MARK: - Convenience

    var isStaticDBAvailable: Bool {
        staticDBError == nil
    }
}
