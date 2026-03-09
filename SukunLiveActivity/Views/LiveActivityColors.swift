import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SÜKÛN — Live Activity Color Tokens
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  Widget extensions run in a separate process and cannot access
//  the main app's named UIColor assets (DS.Color). This enum
//  mirrors the exact hex values from DesignTokens.swift.
//
//  ⚠️  Keep these in sync with DesignTokens.swift UIColor section.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum LAColor {

    // ── Accent (Brushed Gold) ─────────────────────────────────
    static let accentLight = Color(
        .sRGB, red: 0xB0 / 255, green: 0x8D / 255, blue: 0x3E / 255, opacity: 1
    ) // #B08D3E
    static let accentDark = Color(
        .sRGB, red: 0xC8 / 255, green: 0xA5 / 255, blue: 0x58 / 255, opacity: 1
    ) // #C8A558

    // ── Accent Soft Wash ──────────────────────────────────────
    static let accentSoftLight = Color(
        .sRGB, red: 0xB0 / 255, green: 0x8D / 255, blue: 0x3E / 255, opacity: 0.07
    )
    static let accentSoftDark = Color(
        .sRGB, red: 0xC8 / 255, green: 0xA5 / 255, blue: 0x58 / 255, opacity: 0.10
    )

    // ── Text Primary ──────────────────────────────────────────
    static let textPrimaryLight = Color(
        .sRGB, red: 0x1A / 255, green: 0x1A / 255, blue: 0x1C / 255, opacity: 1
    ) // #1A1A1C
    static let textPrimaryDark = Color(
        .sRGB, red: 0xF0 / 255, green: 0xED / 255, blue: 0xE7 / 255, opacity: 1
    ) // #F0EDE7

    // ── Text Secondary ────────────────────────────────────────
    static let textSecondaryLight = Color(
        .sRGB, red: 0x88 / 255, green: 0x85 / 255, blue: 0x7E / 255, opacity: 1
    ) // #88857E
    static let textSecondaryDark = Color(
        .sRGB, red: 0x8C / 255, green: 0x8A / 255, blue: 0x85 / 255, opacity: 1
    ) // #8C8A85

    // ── Backgrounds ───────────────────────────────────────────
    static let bgLight = Color(
        .sRGB, red: 0xF8 / 255, green: 0xF6 / 255, blue: 0xF1 / 255, opacity: 1
    ) // #F8F6F1
    static let bgDark = Color(
        .sRGB, red: 0x0F / 255, green: 0x10 / 255, blue: 0x13 / 255, opacity: 1
    ) // #0F1013

    // ── Hairline ──────────────────────────────────────────────
    static let hairlineLight = Color(
        .sRGB, red: 0xEB / 255, green: 0xE9 / 255, blue: 0xE3 / 255, opacity: 1
    ) // #EBE9E3
    static let hairlineDark = Color(
        .sRGB, red: 0x28 / 255, green: 0x2A / 255, blue: 0x2E / 255, opacity: 1
    ) // #282A2E

    // ── Adaptive Helpers ──────────────────────────────────────

    static func accent(for scheme: ColorScheme) -> Color {
        scheme == .dark ? accentDark : accentLight
    }

    static func textPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textPrimaryDark : textPrimaryLight
    }

    static func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textSecondaryDark : textSecondaryLight
    }

    static func accentSoft(for scheme: ColorScheme) -> Color {
        scheme == .dark ? accentSoftDark : accentSoftLight
    }

    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? bgDark : bgLight
    }

    static func hairline(for scheme: ColorScheme) -> Color {
        scheme == .dark ? hairlineDark : hairlineLight
    }
}
