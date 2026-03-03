import Foundation

protocol RehberLoaderProtocol: Sendable {
    func loadElifba() -> ElifbaData?
    func loadAbdest() -> AbdestData?
    func loadNamaz() -> NamazData?
    func loadLibrary() -> LibraryData?
}

struct RehberLoader: RehberLoaderProtocol {

    func loadElifba() -> ElifbaData? {
        decode("rehber_elifba_tr")
    }

    func loadAbdest() -> AbdestData? {
        decode("rehber_abdest_tr")
    }

    func loadNamaz() -> NamazData? {
        decode("rehber_namaz_tr")
    }

    func loadLibrary() -> LibraryData? {
        decode("rehber_library_tr")
    }

    // MARK: - Private

    private func decode<T: Decodable>(_ resource: String) -> T? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
