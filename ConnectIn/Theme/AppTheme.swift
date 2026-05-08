//
//  AppTheme.swift
//  ConnectIn
//

import SwiftUI
import UIKit

// MARK: - Brand colors
//
// Colors adapt to the system color scheme so the app respects the user's
// Light/Dark preference (Apple HIG: Color and Materials). Brand purples stay
// vivid in both modes; surfaces, text, and borders fully invert.

enum AppTheme {
    enum Colors {
        // Brand purples — slightly brighter variants in dark mode so the
        // gradient banners pop against a near-black surface without losing
        // their identity.
        static let primary = adaptive(
            light: "#3B0764",   // royal-purple-950
            dark: "#5B21B6"     // violet-800
        )
        static let secondary = adaptive(
            light: "#7C3AED",   // violet-600
            dark: "#A78BFA"     // violet-400
        )
        static let accent = adaptive(
            light: "#A855F7",   // purple-500
            dark: "#C084FC"     // purple-400
        )

        // Surfaces
        static let background = adaptive(
            light: "#FAF8FF",   // lavender-tinted white
            dark: "#0F0A1A"     // near-black plum
        )
        static let cardBackground = adaptive(
            light: "#FFFFFF",
            dark: "#1A1428"     // dark plum
        )

        // Text
        static let textPrimary = adaptive(
            light: "#1F1B2E",   // near-black plum
            dark: "#F5F3FF"     // lavender white
        )
        static let textSecondary = adaptive(
            light: "#6B6485",   // muted purple-gray
            dark: "#9D94B8"     // muted lavender-gray
        )

        // Status (kept distinct from brand for legibility, matched to system
        // semantic green/red so they remain unambiguous in both modes).
        static let success = adaptive(light: "#10B981", dark: "#34D399")
        static let error = adaptive(light: "#EF4444", dark: "#F87171")

        // Neutrals — borders, dividers, subtle surfaces.
        static let divider = adaptive(light: "#EAE5F5", dark: "#2A1E40")
        static let inputBorder = adaptive(light: "#DCD2EE", dark: "#3A2B58")
        static let cardBorder = adaptive(light: "#EFEAF7", dark: "#2A1E40")
    }

    /// Default rounded-rectangle radius for buttons, cards, and chips.
    static let cornerRadius: CGFloat = 12

    /// Standard 16-pt grid spacing — matches Apple HIG layout margin.
    static let spacing: CGFloat = 16
}

// MARK: - Adaptive color helpers

private extension AppTheme {
    /// Returns a `Color` that resolves to `light` in light mode and `dark`
    /// in dark mode, using a `UIColor` dynamic provider under the hood.
    /// Centralizing this keeps every theme color one-line and consistent.
    static func adaptive(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }
}

// MARK: - Hex parsing

extension Color {
    /// Parses `#RRGGBB` or `#RRGGBBAA`.
    init(hex: String) {
        self.init(uiColor: UIColor(hex: hex))
    }
}

extension UIColor {
    /// Parses `#RRGGBB` or `#RRGGBBAA` (alpha last). Falls back to black on
    /// malformed input rather than throwing — color helpers shouldn't crash.
    convenience init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&value)

        let r, g, b, a: CGFloat
        switch trimmed.count {
        case 6:
            a = 1
            r = CGFloat((value >> 16) & 0xFF) / 255
            g = CGFloat((value >> 8) & 0xFF) / 255
            b = CGFloat(value & 0xFF) / 255
        case 8:
            a = CGFloat((value >> 24) & 0xFF) / 255
            r = CGFloat((value >> 16) & 0xFF) / 255
            g = CGFloat((value >> 8) & 0xFF) / 255
            b = CGFloat(value & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

// MARK: - Typography
//
// Semantic text styles instead of fixed point sizes so the app respects the
// user's Dynamic Type setting (Apple HIG: Typography). Sizes still match the
// previous design at default Dynamic Type, but they now scale up/down with
// Settings → Display & Brightness → Text Size.

struct ConnectInLargeTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.largeTitle, design: .default, weight: .bold))
    }
}

struct ConnectInTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.title, design: .default, weight: .bold))
    }
}

struct ConnectInHeadlineStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.headline, design: .default, weight: .semibold))
    }
}

struct ConnectInBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.body, design: .default, weight: .regular))
    }
}

struct ConnectInCaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.caption, design: .default, weight: .regular))
    }
}

extension View {
    func connectInLargeTitle() -> some View {
        modifier(ConnectInLargeTitleStyle())
    }

    func connectInTitle() -> some View {
        modifier(ConnectInTitleStyle())
    }

    func connectInHeadline() -> some View {
        modifier(ConnectInHeadlineStyle())
    }

    func connectInBody() -> some View {
        modifier(ConnectInBodyStyle())
    }

    func connectInCaption() -> some View {
        modifier(ConnectInCaptionStyle())
    }
}
