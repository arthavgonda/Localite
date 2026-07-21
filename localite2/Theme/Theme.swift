import SwiftUI

struct Theme {
    let colorScheme: ColorScheme
    var isDark: Bool { colorScheme == .dark }

    let marigold = Color(hex: "EFAE4D")
    let madder = Color(hex: "BD4433")
    let stone = Color(hex: "9C9179")

    var marigoldOnPage: Color {
        isDark ? marigold : Color(hex: "C6852A")
    }

    var background: Color {
        isDark ? Color(hex: "0F0D09") : Color(hex: "F5F1E4")
    }

    var cardBackground: Color {
        Color(hex: "171310")
    }

    var glassBackground: Color {
        Color.white.opacity(0.06)
    }

    var glassBorder: Color {
        Color.white.opacity(0.13)
    }

    var pageGlassBackground: Color {
        isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.045)
    }

    var pageGlassBorder: Color {
        isDark ? Color.white.opacity(0.13) : Color.black.opacity(0.08)
    }

    var shadowColor: Color {
        Color.black.opacity(isDark ? 0.5 : 0.12)
    }

    var textOnCard: Color { Color(hex: "F5EFE1") }

    var textOnCardSecondary: Color { stone }

    var textPrimary: Color {
        isDark ? Color(hex: "F5EFE1") : Color(hex: "2A2116")
    }

    var textSecondary: Color {
        isDark ? stone : Color(hex: "8A7A5E")
    }

    var textOnAccent: Color { Color(hex: "1C1206") }

    static func display(_ size: CGFloat, weight: Font.Weight = .semibold, italic: Bool = false) -> Font {
        let base = Font.custom("Fraunces-SemiBold", size: size)
        return italic ? base.italic() : base
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .custom("IBMPlexMono-SemiBold", size: size).weight(weight)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    func categoryGradient(_ category: CategoryItem.Kind) -> LinearGradient {
        let colors: [Color]
        switch category {
        case .fruit: colors = [Color(hex: "D97B3F"), Color(hex: "8C3B1E")]
        case .vegetable: colors = [Color(hex: "5C7A4A"), Color(hex: "2E4425")]
        case .craft: colors = [Color(hex: "A8623E"), Color(hex: "5C3220")]
        case .textile: colors = [Color(hex: "4A5B8C"), Color(hex: "242C4A")]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension View {
    func theme(_ colorScheme: ColorScheme) -> Theme { Theme(colorScheme: colorScheme) }
}
