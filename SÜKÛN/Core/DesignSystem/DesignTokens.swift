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

        // ── Immersive ──────────────────────────────────────
        /// Deep background for immersive modes (dhikr, quran reader)
        static var surfaceImmersive: SwiftUI.Color {
            SwiftUI.Color(.surfaceImmersive)
        }

        // ── Time-based Gradients ───────────────────────────
        /// Returns a pair of gradient colors keyed to prayer-time periods.
        /// Use for ambient backgrounds that shift throughout the day.
        static func timeGradient(for date: Date = .now) -> [SwiftUI.Color] {
            let hour = Calendar.current.component(.hour, from: date)
            switch hour {
            case 4..<7:   // Fajr — dawn rose + deep blue
                return [SwiftUI.Color(hex: 0xF4C6A5, opacity: 0.25),
                        SwiftUI.Color(hex: 0x2B3A67, opacity: 0.20)]
            case 7..<12:  // Morning — warm ivory + soft gold
                return [SwiftUI.Color(hex: 0xF5E6C8, opacity: 0.20),
                        SwiftUI.Color(hex: 0xDBC68F, opacity: 0.12)]
            case 12..<15: // Dhuhr — bright gold + warm white
                return [SwiftUI.Color(hex: 0xF0D890, opacity: 0.18),
                        SwiftUI.Color(hex: 0xFFF8E8, opacity: 0.10)]
            case 15..<18: // Asr — amber + soft orange
                return [SwiftUI.Color(hex: 0xE8B86D, opacity: 0.22),
                        SwiftUI.Color(hex: 0xD4845A, opacity: 0.14)]
            case 18..<20: // Maghrib — sunset copper + deep purple
                return [SwiftUI.Color(hex: 0xD47B5E, opacity: 0.25),
                        SwiftUI.Color(hex: 0x4A2D6B, opacity: 0.18)]
            default:      // Isha — deep navy + midnight teal
                return [SwiftUI.Color(hex: 0x1A2744, opacity: 0.28),
                        SwiftUI.Color(hex: 0x0F2027, opacity: 0.22)]
            }
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

        // ── Serif Display (Cormorant Garamond) ──────────────
        //    Editorial headlines that carry the brand's voice.
        //    Falls back to system serif if custom font unavailable.

        /// 48pt serif bold — onboarding titles, hero text
        static let displayHero = cormorant(size: 48, weight: "Bold")
        /// 36pt serif bold — large section heroes
        static let displayTitle = cormorant(size: 36, weight: "Bold")
        /// 32pt serif semibold — card/section heroes
        static let displaySubtitle = cormorant(size: 32, weight: "SemiBold")
        /// 22pt serif regular — editorial card titles
        static let displayBody = cormorant(size: 22, weight: "Regular")
        /// 13pt serif medium italic — source references, attributions
        static let serifSource = cormorant(size: 13, weight: "MediumItalic")
        /// 14pt serif italic — Hijri dates, cultural context
        static let serifDate = cormorant(size: 14, weight: "Italic")

        // ── Display Scale ────────────────────────────────────
        /// 96pt black — giant countdown numbers
        static let mega        = Font.system(size: 96, weight: .black, design: .default)
        /// 72pt heavy — hero counters
        static let giga        = Font.system(size: 72, weight: .heavy, design: .default)
        /// 48pt bold — section heroes
        static let hero        = Font.system(size: 48, weight: .bold, design: .default)
        /// 28pt bold — screen titles (AlongSanss2)
        static let title1      = alongSans(size: 28, weight: "Bold")
        /// 22pt semibold — card titles (AlongSanss2)
        static let title2      = alongSans(size: 22, weight: "SemiBold")
        /// 17pt semibold — section headlines (AlongSanss2)
        static let headline    = alongSans(size: 17, weight: "SemiBold")
        /// 12pt semibold — section labels, uppercase trackers (AlongSanss2)
        static let sectionHead = alongSans(size: 12, weight: "SemiBold")
        /// 17pt — body text (AlongSanss2)
        static let body        = alongSans(size: 17, weight: "Regular")
        /// 12pt — captions (AlongSanss2)
        static let caption     = alongSans(size: 12, weight: "Regular")
        /// 11pt — small captions (AlongSanss2)
        static let captionSm   = alongSans(size: 11, weight: "Regular")
        /// 9pt medium — micro labels (AlongSanss2)
        static let micro       = alongSans(size: 9, weight: "Medium")

        // ── UI Labels (buttons, badges, chips) ───────────────
        /// 17pt semibold — primary button labels (AlongSanss2)
        static let buttonLabel = alongSans(size: 17, weight: "SemiBold")
        /// 15pt medium — secondary text, form labels (AlongSanss2)
        static let bodyMedium  = alongSans(size: 15, weight: "Medium")
        /// 16pt medium — list item titles (AlongSanss2)
        static let listTitle   = alongSans(size: 16, weight: "Medium")
        /// 13pt regular — auxiliary info, metadata (AlongSanss2)
        static let footnote    = alongSans(size: 13, weight: "Regular")
        /// 10pt bold — chip labels, uppercase tags (AlongSanss2)
        static let chipLabel   = alongSans(size: 10, weight: "Bold")
        /// 11pt bold — section tracker labels, uppercase (AlongSanss2)
        static let trackerLabel = alongSans(size: 11, weight: "Bold")

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

        /// Arabic verse text — uses Amiri if available, system otherwise
        static let arabicVerse      = amiri(size: 24)
        /// Arabic large — expanded verse display
        static let arabicLarge      = amiri(size: 28)
        /// Arabic hero — section heroes
        static let arabicHero       = amiri(size: 32)
        /// Arabic display — large decorative text
        static let arabicDisplay    = amiri(size: 40)
        /// Bismillah — opening formula
        static let arabicBismillah  = amiri(size: 22)
        /// Arabic bold — emphasis, headers
        static let arabicBold       = amiriBold(size: 22)

        static let surahTitle       = alongSans(size: 15, weight: "SemiBold")
        static let verseNumber      = Font.system(size: 11, weight: .medium, design: .rounded)
        static let pageNumber       = Font.system(size: 12, weight: .medium, design: .rounded)

        // ── Transliteration (Cormorant italic) ──────────────
        static let transliteration   = cormorant(size: 15, weight: "Italic")
        static let transliterationSm = cormorant(size: 13, weight: "Italic")
        static let transliterationLg = cormorant(size: 17, weight: "Italic")

        // ── Font Factories ──────────────────────────────────

        /// Cormorant Garamond with system serif fallback.
        static func cormorant(size: CGFloat, weight: String = "Regular") -> Font {
            let name = "CormorantGaramond-\(weight)"
            if UIFont(name: name, size: size) != nil {
                return .custom(name, size: size)
            }
            // Fallback to system serif
            let w: Font.Weight = switch weight {
            case "Bold": .bold
            case "SemiBold": .semibold
            case "MediumItalic", "Italic": .regular
            default: .regular
            }
            return .system(size: size, weight: w, design: .serif)
        }

        /// AlongSanss2 geometric sans-serif with system fallback.
        /// Used for all UI labels, buttons, navigation, and body text.
        static func alongSans(size: CGFloat, weight: String = "Regular") -> Font {
            let name = "AlongSanss2-\(weight)"
            if UIFont(name: name, size: size) != nil {
                return .custom(name, size: size, relativeTo: .body)
            }
            // Fallback to system default
            let w: Font.Weight = switch weight {
            case "Black": .black
            case "ExtraBold": .heavy
            case "Bold": .bold
            case "SemiBold": .semibold
            case "Medium": .medium
            default: .regular
            }
            return .system(size: size, weight: w, design: .default)
        }

        /// Amiri Arabic with system fallback.
        static func amiri(size: CGFloat) -> Font {
            if UIFont(name: "Amiri", size: size) != nil {
                return .custom("Amiri", size: size)
            }
            return .system(size: size, weight: .regular)
        }

        /// Amiri Bold Arabic with system fallback.
        private static func amiriBold(size: CGFloat) -> Font {
            if UIFont(name: "Amiri-Bold", size: size) != nil {
                return .custom("Amiri-Bold", size: size)
            }
            return .system(size: size, weight: .bold)
        }

        /// Returns a Font for KFGQPC Uthmanic Script if available,
        /// Amiri if available, system Arabic otherwise.
        static func arabicUthmanic(size: CGFloat) -> Font {
            if UIFont(name: "KFGQPCUthmanicScriptHAFS", size: size) != nil {
                return .custom("KFGQPCUthmanicScriptHAFS", size: size)
            }
            return amiri(size: size)
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
        
        // ── PREMIUM OVERHAUL SHADOWS ────────────────────────
        /// Ultra-premium diffuse multi-layered shadow for main cards
        static let premiumCard = ShadowToken(
            color: .black.opacity(0.06), radius: 20, y: 8
        )
        /// Deep ambient shadow for immersive modal depth
        static let deepAmbient = ShadowToken(
            color: .black.opacity(0.12), radius: 32, y: 16
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
            // Premium glass gradient border reflection
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                DS.Color.glassBorder.opacity(0.8),
                                DS.Color.glassBorder.opacity(0.1),
                                DS.Color.glassBorder.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            // Ambient interior shadow for deeper glass illusion
            .shadow(color: .white.opacity(0.05), radius: 2, x: 0, y: 1)
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

    // ── Immersive ──────────────────────────────────────

    /// Deep surface for immersive screens (dhikr, mushaf reader)
    static let surfaceImmersive = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x08/255, green: 0x09/255, blue: 0x0C/255, alpha: 1)   // #08090C
            : UIColor(red: 0xF2/255, green: 0xF0/255, blue: 0xEB/255, alpha: 1)   // #F2F0EB
    }
}
