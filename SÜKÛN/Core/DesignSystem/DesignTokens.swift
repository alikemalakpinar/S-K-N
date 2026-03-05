import SwiftUI

// MARK: - DS Namespace

enum DS {}

// MARK: - Color Tokens

extension DS {
    enum Color {
        static var backgroundPrimary: SwiftUI.Color {
            SwiftUI.Color(.backgroundPrimary)
        }
        static var backgroundSecondary: SwiftUI.Color {
            SwiftUI.Color(.backgroundSecondary)
        }
        static var hairline: SwiftUI.Color {
            SwiftUI.Color(.hairline)
        }
        static var textPrimary: SwiftUI.Color {
            SwiftUI.Color(.textPrimary)
        }
        static var textSecondary: SwiftUI.Color {
            SwiftUI.Color(.textSecondary)
        }
        static var accent: SwiftUI.Color {
            SwiftUI.Color(.dsAccent)
        }
        static var quranCard: SwiftUI.Color {
            SwiftUI.Color(.quranCardBg)
        }
        static var surahHeader: SwiftUI.Color {
            SwiftUI.Color(.surahHeaderBg)
        }
        static var accentSoft: SwiftUI.Color {
            SwiftUI.Color(.accentSoft)
        }
        static var ornamentLine: SwiftUI.Color {
            SwiftUI.Color(.ornamentLine)
        }
        static var textTertiary: SwiftUI.Color {
            SwiftUI.Color(.textTertiary)
        }
        static var cardElevated: SwiftUI.Color {
            SwiftUI.Color(.cardElevated)
        }
    }
}

// MARK: - Spacing Scale

extension DS {
    enum Space {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 12
        static let lg:  CGFloat = 16
        static let xl:  CGFloat = 24
        static let x2:  CGFloat = 32
        static let x3:  CGFloat = 40
        static let x4:  CGFloat = 48
    }
}

// MARK: - Typography

extension DS {
    enum Typography {
        // Ultra-modern scale
        static let mega        = Font.system(size: 96, weight: .black, design: .default)
        static let giga        = Font.system(size: 72, weight: .heavy, design: .default)
        static let hero        = Font.system(size: 48, weight: .bold, design: .default)
        static let title1      = Font.system(size: 28, weight: .bold, design: .default)
        static let title2      = Font.system(size: 22, weight: .semibold, design: .default)
        static let headline    = Font.headline
        static let sectionHead = Font.system(size: 12, weight: .semibold, design: .default)
        static let body        = Font.body
        static let caption     = Font.caption
        static let captionSm   = Font.caption2
        static let micro       = Font.system(size: 9, weight: .medium, design: .default)

        // Monospaced numbers for timers/counters
        static let monoMega    = Font.system(size: 96, weight: .black, design: .monospaced)
        static let monoGiga    = Font.system(size: 72, weight: .heavy, design: .monospaced)
        static let monoHero    = Font.system(size: 48, weight: .bold, design: .monospaced)
        static let monoTitle   = Font.system(size: 28, weight: .bold, design: .monospaced)

        // Quran-specific typography
        static let arabicVerse   = Font.system(size: 24, weight: .regular)
        static let arabicLarge   = Font.system(size: 28, weight: .regular)
        static let arabicHero    = Font.system(size: 32, weight: .regular)
        static let arabicBismillah = Font.system(size: 22, weight: .regular)
        static let surahTitle    = Font.system(size: 15, weight: .semibold, design: .default)
        static let verseNumber   = Font.system(size: 11, weight: .medium, design: .rounded)
        static let pageNumber    = Font.system(size: 12, weight: .medium, design: .rounded)

        // Transliteration typography
        static let transliteration   = Font.system(size: 15, weight: .regular, design: .serif)
        static let transliterationSm = Font.system(size: 13, weight: .regular, design: .serif)
    }
}

// MARK: - Font Scale Environment Key

private struct DSFontScaleKey: EnvironmentKey {
    static let defaultValue: Double = 1.0
}

extension EnvironmentValues {
    var dsFontScale: Double {
        get { self[DSFontScaleKey.self] }
        set { self[DSFontScaleKey.self] = newValue }
    }
}

// MARK: - Hex Color Initializer

extension SwiftUI.Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - UIColor definitions (adaptive light/dark)
// Light-first palette: warm, calming, airy

extension UIColor {
    // Warm ivory — like premium paper
    static let backgroundPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x12/255, green: 0x13/255, blue: 0x16/255, alpha: 1)
            : UIColor(red: 0xF8/255, green: 0xF6/255, blue: 0xF1/255, alpha: 1)
    }

    // Pure white — cards float above
    static let backgroundSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x1A/255, green: 0x1C/255, blue: 0x20/255, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }

    // Warm subtle separator
    static let hairline = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x2A/255, green: 0x2C/255, blue: 0x30/255, alpha: 1)
            : UIColor(red: 0xEC/255, green: 0xEA/255, blue: 0xE4/255, alpha: 1)
    }

    // Near-black for maximum contrast on light
    static let textPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xF0/255, green: 0xEE/255, blue: 0xE9/255, alpha: 1)
            : UIColor(red: 0x1C/255, green: 0x1C/255, blue: 0x1E/255, alpha: 1)
    }

    // Warm gray — not blue/cold
    static let textSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x8A/255, green: 0x8A/255, blue: 0x8E/255, alpha: 1)
            : UIColor(red: 0x8A/255, green: 0x87/255, blue: 0x80/255, alpha: 1)
    }

    // Rich warm gold — vibrant, premium
    static let dsAccent = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xC4/255, green: 0xA1/255, blue: 0x54/255, alpha: 1)
            : UIColor(red: 0xB0/255, green: 0x8D/255, blue: 0x3E/255, alpha: 1)
    }

    // Quran parchment card
    static let quranCardBg = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x1E/255, green: 0x20/255, blue: 0x25/255, alpha: 1)
            : UIColor(red: 0xFF/255, green: 0xFE/255, blue: 0xFB/255, alpha: 1)
    }

    // Surah header warm beige
    static let surahHeaderBg = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x22/255, green: 0x24/255, blue: 0x2A/255, alpha: 1)
            : UIColor(red: 0xF5/255, green: 0xF1/255, blue: 0xE8/255, alpha: 1)
    }

    // Soft accent wash
    static let accentSoft = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xC4/255, green: 0xA1/255, blue: 0x54/255, alpha: 0.12)
            : UIColor(red: 0xB0/255, green: 0x8D/255, blue: 0x3E/255, alpha: 0.08)
    }

    // Ornamental gold line
    static let ornamentLine = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xC4/255, green: 0xA1/255, blue: 0x54/255, alpha: 0.25)
            : UIColor(red: 0xB0/255, green: 0x8D/255, blue: 0x3E/255, alpha: 0.2)
    }

    // Ghost text — for giant background numbers
    static let textTertiary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x2E/255, green: 0x30/255, blue: 0x36/255, alpha: 1)
            : UIColor(red: 0xE0/255, green: 0xDD/255, blue: 0xD6/255, alpha: 1)
    }

    // White card on ivory — elevated, floating
    static let cardElevated = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x1E/255, green: 0x20/255, blue: 0x25/255, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
}
