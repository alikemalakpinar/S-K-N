import Foundation

@Observable
final class RehberViewModel {
    var elifba: ElifbaData?
    var abdest: AbdestData?
    var namaz: NamazData?
    var library: LibraryData?
    var isLoaded = false

    private let loader: any RehberLoaderProtocol

    init(container: DependencyContainer) {
        self.loader = container.rehberLoader
    }

    func loadAll() {
        guard !isLoaded else { return }
        elifba = loader.loadElifba()
        abdest = loader.loadAbdest()
        namaz = loader.loadNamaz()
        library = loader.loadLibrary()
        isLoaded = true
    }

    func libraryReading(for refId: String?) -> LibraryReading? {
        guard let refId else { return nil }
        return library?.readings.first { $0.id == refId }
    }
}
