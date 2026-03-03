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
        static let hero        = Font.system(size: 44, weight: .medium, design: .default)
        static let sectionHead = Font.system(size: 13, weight: .medium, design: .default)
        static let body        = Font.system(size: 17, weight: .regular, design: .default)
        static let caption     = Font.system(size: 13, weight: .regular, design: .default)
        static let captionSm   = Font.system(size: 11, weight: .regular, design: .default)
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

extension UIColor {
    static let backgroundPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x0E/255, green: 0x0F/255, blue: 0x12/255, alpha: 1)
            : UIColor(red: 0xF6/255, green: 0xF4/255, blue: 0xEF/255, alpha: 1)
    }

    static let backgroundSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x14/255, green: 0x16/255, blue: 0x1A/255, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }

    static let hairline = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x1F/255, green: 0x21/255, blue: 0x26/255, alpha: 1)
            : UIColor(red: 0xE5/255, green: 0xE5/255, blue: 0xE5/255, alpha: 1)
    }

    static let textPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xF2/255, green: 0xF2/255, blue: 0xF2/255, alpha: 1)
            : UIColor(red: 0x1A/255, green: 0x1A/255, blue: 0x1A/255, alpha: 1)
    }

    static let textSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x9C/255, green: 0xA3/255, blue: 0xAF/255, alpha: 1)
            : UIColor(red: 0x6B/255, green: 0x72/255, blue: 0x80/255, alpha: 1)
    }

    static let dsAccent = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xB8/255, green: 0x9B/255, blue: 0x5E/255, alpha: 1)
            : UIColor(red: 0x9A/255, green: 0x7C/255, blue: 0x3D/255, alpha: 1)
    }
}
