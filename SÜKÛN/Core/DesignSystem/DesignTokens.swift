import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN Design System — Foundation Tokens
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  A warm, contemplative palette inspired by aged parchment,
//  brushed gold calligraphy, and the quiet light of a mosque
//  at dawn. Every token is adaptive for Light ↔ Dark.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum DS {}

// MARK: - Color Tokens

extension DS {
    enum Color {
        // ── Backgrounds ──────────────────────────────────────
        /// Primary canvas — warm ivory / deep charcoal
        static var backgroundPrimary: SwiftUI.Color {
            SwiftUI.Color(.backgroundPrimary)
        }
        /// Secondary surface — pure white / elevated dark
        static var backgroundSecondary: SwiftUI.Color {
            SwiftUI.Color(.backgroundSecondary)
        }

        // ── Text ─────────────────────────────────────────────
        /// Primary text — near-black / warm off-white
        static var textPrimary: SwiftUI.Color {
            SwiftUI.Color(.textPrimary)
        }
        /// Secondary text — warm gray
        static var textSecondary: SwiftUI.Color {
            SwiftUI.Color(.textSecondary)
        }
        /// Tertiary text — ghost/background numbers
        static var textTertiary: SwiftUI.Color {
            SwiftUI.Color(.textTertiary)
        }

        // ── Accent ───────────────────────────────────────────
        /// Rich warm gold — the signature accent
        static var accent: SwiftUI.Color {
            SwiftUI.Color(.dsAccent)
        }
        /// Soft accent wash — tinted backgrounds, pills
        static var accentSoft: SwiftUI.Color {
            SwiftUI.Color(.accentSoft)
        }

        // ── Lines & Ornaments ────────────────────────────────
        /// Subtle separator
        static var hairline: SwiftUI.Color {
            SwiftUI.Color(.hairline)
        }
        /// Decorative gold rule
        static var ornamentLine: SwiftUI.Color {
            SwiftUI.Color(.ornamentLine)
        }

        // ── Surfaces ────────────────────────────────────────
        /// Floating card — white on ivory / elevated dark
        static var cardElevated: SwiftUI.Color {
            SwiftUI.Color(.cardElevated)
        }
        /// Quran parchment card
        static var quranCard: SwiftUI.Color {
            SwiftUI.Color(.quranCardBg)
        }
        /// Surah header warm beige
        static var surahHeader: SwiftUI.Color {
            SwiftUI.Color(.surahHeaderBg)
        }

        // ── Semantic ────────────────────────────────────────
        /// Success — prayer logged, goal reached
        static var success: SwiftUI.Color {
            SwiftUI.Color(.dsSuccess)
        }
        /// Warning — calibration needed, missed prayers
        static var warning: SwiftUI.Color {
            SwiftUI.Color(.dsWarning)
        }

        // ── Glass ───────────────────────────────────────────
        /// Frosted glass fill for overlays and sheets
        static var glassFill: SwiftUI.Color {
            SwiftUI.Color(.glassFill)
        }
        /// Glass border — subtle edge catch
        static var glassBorder: SwiftUI.Color {
            SwiftUI.Color(.glassBorder)
        }
    }
}

// MARK: - Spacing Scale (4pt base grid)

extension DS {
    enum Space {
        /// 4pt — hairline gaps, icon padding
        static let xs:  CGFloat = 4
        /// 8pt — tight element spacing
        static let sm:  CGFloat = 8
        /// 12pt — standard inner padding
        static let md:  CGFloat = 12
        /// 16pt — card padding, section gaps
        static let lg:  CGFloat = 16
        /// 24pt — section spacing
        static let xl:  CGFloat = 24
        /// 32pt — major section breaks
        static let x2:  CGFloat = 32
        /// 40pt — hero spacing
        static let x3:  CGFloat = 40
        /// 48pt — screen-level spacing
        static let x4:  CGFloat = 48
        /// 64pt — dramatic whitespace
        static let x5:  CGFloat = 64
    }
}

// MARK: - Typography

extension DS {
    enum Typography {
        // ── Display Scale ────────────────────────────────────
        /// 96pt black — giant countdown numbers
        static let mega        = Font.system(size: 96, weight: .black, design: .default)
        /// 72pt heavy — hero counters
        static let giga        = Font.system(size: 72, weight: .heavy, design: .default)
        /// 48pt bold — section heroes
        static let hero        = Font.system(size: 48, weight: .bold, design: .default)
        /// 28pt bold — screen titles
        static let title1      = Font.system(size: 28, weight: .bold, design: .default)
        /// 22pt semibold — card titles
        static let title2      = Font.system(size: 22, weight: .semibold, design: .default)
        /// 17pt semibold — section headlines
        static let headline    = Font.headline
        /// 12pt semibold — section labels, uppercase trackers
        static let sectionHead = Font.system(size: 12, weight: .semibold, design: .default)
        /// 17pt — body text
        static let body        = Font.body
        /// 12pt — captions
        static let caption     = Font.caption
        /// 11pt — small captions
        static let captionSm   = Font.caption2
        /// 9pt medium — micro labels
        static let micro       = Font.system(size: 9, weight: .medium, design: .default)

        // ── UI Labels (buttons, badges, chips) ───────────────
        /// 17pt semibold — primary button labels
        static let buttonLabel = Font.system(size: 17, weight: .semibold, design: .default)
        /// 15pt medium — secondary text, form labels
        static let bodyMedium  = Font.system(size: 15, weight: .medium, design: .default)
        /// 16pt medium — list item titles
        static let listTitle   = Font.system(size: 16, weight: .medium, design: .default)
        /// 13pt regular — auxiliary info, metadata
        static let footnote    = Font.system(size: 13, weight: .regular, design: .default)
        /// 10pt bold — chip labels, uppercase tags
        static let chipLabel   = Font.system(size: 10, weight: .bold, design: .default)
        /// 11pt bold — section tracker labels, uppercase
        static let trackerLabel = Font.system(size: 11, weight: .bold, design: .default)

        // ── Monospaced (timers, counters) ────────────────────
        static let monoMega    = Font.system(size: 96, weight: .black, design: .monospaced)
        static let monoGiga    = Font.system(size: 72, weight: .heavy, design: .monospaced)
        static let monoHero    = Font.system(size: 48, weight: .bold, design: .monospaced)
        static let monoTitle   = Font.system(size: 28, weight: .bold, design: .monospaced)
        static let monoBody    = Font.system(size: 17, weight: .medium, design: .monospaced)

        // ── Rounded (counters, badges, friendly UI) ──────────
        static let roundedHero   = Font.system(size: 48, weight: .bold, design: .rounded)
        static let roundedTitle  = Font.system(size: 28, weight: .bold, design: .rounded)
        static let roundedBody   = Font.system(size: 17, weight: .medium, design: .rounded)
        static let roundedCaption = Font.system(size: 13, weight: .semibold, design: .rounded)

        // ── Arabic / Quranic ─────────────────────────────────
        //    Uses system Arabic rendering with carefully tuned sizes.
        //    For custom Uthmanic Script, use .arabicUthmanic() below.
        static let arabicVerse      = Font.system(size: 24, weight: .regular)
        static let arabicLarge      = Font.system(size: 28, weight: .regular)
        static let arabicHero       = Font.system(size: 32, weight: .regular)
        static let arabicDisplay    = Font.system(size: 40, weight: .regular)
        static let arabicBismillah  = Font.system(size: 22, weight: .regular)
        static let surahTitle       = Font.system(size: 15, weight: .semibold, design: .default)
        static let verseNumber      = Font.system(size: 11, weight: .medium, design: .rounded)
        static let pageNumber       = Font.system(size: 12, weight: .medium, design: .rounded)

        // ── Transliteration (serif italic) ───────────────────
        static let transliteration   = Font.system(size: 15, weight: .regular, design: .serif)
        static let transliterationSm = Font.system(size: 13, weight: .regular, design: .serif)
        static let transliterationLg = Font.system(size: 17, weight: .regular, design: .serif)

        // ── Uthmanic Script ──────────────────────────────────
        /// Returns a Font for KFGQPC Uthmanic Script if available, system Arabic otherwise.
        static func arabicUthmanic(size: CGFloat) -> Font {
            if let _ = UIFont(name: "KFGQPCUthmanicScriptHAFS", size: size) {
                return .custom("KFGQPCUthmanicScriptHAFS", size: size)
            }
            return .system(size: size, weight: .regular)
        }

        // ── Line Spacing Presets ─────────────────────────────
        enum LineSpacing {
            /// Arabic text — generous breathing room
            static let arabic: CGFloat = 16
            /// Arabic in compact layouts
            static let arabicCompact: CGFloat = 10
            /// Translation/body text
            static let body: CGFloat = 6
            /// Transliteration
            static let transliteration: CGFloat = 5
        }
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

// MARK: - Corner Radius

extension DS {
    enum Radius {
        /// 8pt — small chips, pills
        static let sm: CGFloat = 8
        /// 12pt — inner cards, buttons
        static let md: CGFloat = 12
        /// 16pt — standard cards
        static let lg: CGFloat = 16
        /// 20pt — hero cards, surah headers
        static let xl: CGFloat = 20
        /// 24pt — sheets, large modals
        static let x2: CGFloat = 24
        /// Continuous corner rounding (iOS-native feel)
        static let continuous: CGFloat = 16
    }
}

// MARK: - Shadow Presets

extension DS {
    enum Shadow {
        /// Barely-there lift — cards on ivory
        static let card = ShadowToken(color: .black.opacity(0.04), radius: 8, y: 2)
        /// Medium elevation — floating sheets
        static let elevated = ShadowToken(color: .black.opacity(0.08), radius: 16, y: 4)
        /// Strong depth — modals, overlays
        static let modal = ShadowToken(color: .black.opacity(0.14), radius: 24, y: 8)
        /// Accent glow — active/selected elements
        static let accentGlow = ShadowToken(
            color: SwiftUI.Color(.dsAccent).opacity(0.25), radius: 12, y: 4
        )
    }
}

struct ShadowToken {
    let color: SwiftUI.Color
    let radius: CGFloat
    let y: CGFloat
}

// MARK: - Glassmorphism View Modifier

extension DS {
    enum Glass {
        /// Ultra-thin material — lightest frosted glass
        static let ultraThin: Material = .ultraThinMaterial
        /// Thin material — subtle blur
        static let thin: Material = .thinMaterial
        /// Regular material — standard frosted glass
        static let regular: Material = .regularMaterial
        /// Thick material — heavy frosted glass
        static let thick: Material = .thickMaterial
    }
}

struct DSGlassModifier: ViewModifier {
    var material: Material = .thinMaterial
    var cornerRadius: CGFloat = DS.Radius.lg

    func body(content: Content) -> some View {
        content
            .background(material, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DS.Color.glassBorder, lineWidth: 0.5)
            )
    }
}

extension View {
    /// Apply frosted glass effect with border highlight.
    func dsGlass(
        _ material: Material = .thinMaterial,
        cornerRadius: CGFloat = DS.Radius.lg
    ) -> some View {
        modifier(DSGlassModifier(material: material, cornerRadius: cornerRadius))
    }

    /// Apply a DS shadow preset.
    func dsShadow(_ token: ShadowToken) -> some View {
        shadow(color: token.color, radius: token.radius, y: token.y)
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - UIColor Definitions (Adaptive Light / Dark)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Light: warm ivory, brushed gold, parchment warmth
// Dark:  deep charcoal with amber/gold undertones
//

extension UIColor {

    // ── Backgrounds ──────────────────────────────────────

    /// Warm ivory / deep charcoal
    static let backgroundPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x0F/255, green: 0x10/255, blue: 0x13/255, alpha: 1)   // #0F1013
            : UIColor(red: 0xF8/255, green: 0xF6/255, blue: 0xF1/255, alpha: 1)   // #F8F6F1
    }

    /// Pure white / slightly elevated dark
    static let backgroundSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x18/255, green: 0x1A/255, blue: 0x1E/255, alpha: 1)   // #181A1E
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)                         // #FFFFFF
    }

    // ── Text ─────────────────────────────────────────────

    /// Near-black / warm off-white
    static let textPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xF0/255, green: 0xED/255, blue: 0xE7/255, alpha: 1)   // #F0EDE7
            : UIColor(red: 0x1A/255, green: 0x1A/255, blue: 0x1C/255, alpha: 1)   // #1A1A1C
    }

    /// Warm gray
    static let textSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x8C/255, green: 0x8A/255, blue: 0x85/255, alpha: 1)   // #8C8A85
            : UIColor(red: 0x88/255, green: 0x85/255, blue: 0x7E/255, alpha: 1)   // #88857E
    }

    /// Ghost — for oversized background elements
    static let textTertiary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x28/255, green: 0x2A/255, blue: 0x2F/255, alpha: 1)   // #282A2F
            : UIColor(red: 0xE0/255, green: 0xDD/255, blue: 0xD6/255, alpha: 1)   // #E0DDD6
    }

    // ── Accent ───────────────────────────────────────────

    /// Rich warm gold
    static let dsAccent = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xC8/255, green: 0xA5/255, blue: 0x58/255, alpha: 1)   // #C8A558
            : UIColor(red: 0xB0/255, green: 0x8D/255, blue: 0x3E/255, alpha: 1)   // #B08D3E
    }

    /// Soft accent wash — tinted fills
    static let accentSoft = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xC8/255, green: 0xA5/255, blue: 0x58/255, alpha: 0.10)
            : UIColor(red: 0xB0/255, green: 0x8D/255, blue: 0x3E/255, alpha: 0.07)
    }

    // ── Lines & Ornaments ────────────────────────────────

    /// Warm subtle separator
    static let hairline = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x28/255, green: 0x2A/255, blue: 0x2E/255, alpha: 1)   // #282A2E
            : UIColor(red: 0xEB/255, green: 0xE9/255, blue: 0xE3/255, alpha: 1)   // #EBE9E3
    }

    /// Decorative gold line
    static let ornamentLine = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xC8/255, green: 0xA5/255, blue: 0x58/255, alpha: 0.22)
            : UIColor(red: 0xB0/255, green: 0x8D/255, blue: 0x3E/255, alpha: 0.18)
    }

    // ── Surfaces ────────────────────────────────────────

    /// Elevated card — white / dark elevated
    static let cardElevated = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x1C/255, green: 0x1E/255, blue: 0x23/255, alpha: 1)   // #1C1E23
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)                         // #FFFFFF
    }

    /// Quran parchment card
    static let quranCardBg = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x1A/255, green: 0x1C/255, blue: 0x22/255, alpha: 1)   // #1A1C22
            : UIColor(red: 0xFF/255, green: 0xFE/255, blue: 0xFB/255, alpha: 1)   // #FFFEFB
    }

    /// Surah header warm beige
    static let surahHeaderBg = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x20/255, green: 0x22/255, blue: 0x28/255, alpha: 1)   // #202228
            : UIColor(red: 0xF4/255, green: 0xF0/255, blue: 0xE7/255, alpha: 1)   // #F4F0E7
    }

    // ── Semantic ────────────────────────────────────────

    /// Success green
    static let dsSuccess = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x4A/255, green: 0xBB/255, blue: 0x7D/255, alpha: 1)   // #4ABB7D
            : UIColor(red: 0x34/255, green: 0xA8/255, blue: 0x53/255, alpha: 1)   // #34A853
    }

    /// Warning amber
    static let dsWarning = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xE0/255, green: 0xA0/255, blue: 0x40/255, alpha: 1)   // #E0A040
            : UIColor(red: 0xD4/255, green: 0x8C/255, blue: 0x2C/255, alpha: 1)   // #D48C2C
    }

    // ── Glass ───────────────────────────────────────────

    /// Translucent glass fill
    static let glassFill = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.06)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 0.60)
    }

    /// Glass border — subtle edge highlight
    static let glassBorder = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1, green: 1, blue: 1, alpha: 0.10)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 0.70)
    }
}
