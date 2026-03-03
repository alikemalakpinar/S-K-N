import Foundation

// MARK: - Elifba

struct ElifbaData: Codable, Sendable {
    let title: String
    let items: [ElifbaLetter]
}

struct ElifbaLetter: Codable, Identifiable, Sendable {
    let id: String
    let symbol: String
    let name: String
    let description: String
    let forms: LetterForms
}

struct LetterForms: Codable, Sendable {
    let initial: String
    let medial: String
    let final: String
}

// MARK: - Abdest

struct AbdestData: Codable, Sendable {
    let title: String
    let steps: [AbdestStep]
}

struct AbdestStep: Codable, Identifiable, Sendable {
    var id: Int { order }
    let order: Int
    let title: String
    let text: String
    let iconName: String
}

// MARK: - Namaz

struct NamazData: Codable, Sendable {
    let title: String
    let postures: [NamazPosture]
}

struct NamazPosture: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let actionText: String
    let recitation: Recitation?
    let libraryRefId: String?
}

struct Recitation: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let meaning: String
}

// MARK: - Library

struct LibraryData: Codable, Sendable {
    let readings: [LibraryReading]
}

struct LibraryReading: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let arabic: String
    let transliteration: String
    let meaning: String
}
