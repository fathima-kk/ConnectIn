//
//  AppTheme.swift
//  ConnectIn
//

import SwiftUI

// MARK: - Brand colors

enum AppTheme {
    enum Colors {
        static let primary = Color(hex: "#052259")
        static let secondary = Color(hex: "#0891B2")
        static let accent = Color(hex: "#06B6D4")
        static let background = Color(hex: "#F8FAFF")
        static let cardBackground = Color(hex: "#FFFFFF")
        static let textPrimary = Color(hex: "#1F2937")
        static let textSecondary = Color(hex: "#6B7280")
        static let success = Color(hex: "#10B981")
        static let error = Color(hex: "#EF4444")
    }

    static let cornerRadius: CGFloat = 12
    static let spacing: CGFloat = 16
}

// MARK: - Hex colors

extension Color {
    /// Parses `#RRGGBB` or `#RRGGBBAA` (alpha last).
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)

        let r, g, b, a: Double
        switch hex.count {
        case 6:
            a = 1
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
        case 8:
            a = Double((value >> 24) & 0xFF) / 255
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
        default:
            a = 1
            r = 0
            g = 0
            b = 0
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Typography (SF Pro is the system default on iOS)

private enum FontSize {
    static let largeTitle: CGFloat = 34
    static let title: CGFloat = 28
    static let headline: CGFloat = 17
    static let body: CGFloat = 17
    static let caption: CGFloat = 12
}

struct ConnectInLargeTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: FontSize.largeTitle, weight: .bold, design: .default))
    }
}

struct ConnectInTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: FontSize.title, weight: .bold, design: .default))
    }
}

struct ConnectInHeadlineStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: FontSize.headline, weight: .semibold, design: .default))
    }
}

struct ConnectInBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: FontSize.body, weight: .regular, design: .default))
    }
}

struct ConnectInCaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: FontSize.caption, weight: .regular, design: .default))
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
