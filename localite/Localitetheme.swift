//
//  LocaliteTheme.swift
//  localite
//
//  Created by ANOOP on 18/07/26.
//

import SwiftUI

enum LocaliteTheme {
    static let background = Color.white
    static let surface = Color.white
    static let ink = Color.black
    static let inkSecondary = Color(white: 0.32)
    static let inkMuted = Color(white: 0.56)
    static let accent = Color(red: 0.745, green: 0.161, blue: 0.106)
    static let hairline = Color.black.opacity(0.1)
    static let surfaceMuted = Color(red: 0.937, green: 0.937, blue: 0.918)

    enum Passport {
        static let gradientTop = Color(red: 0.184, green: 0.322, blue: 0.200)
        static let gradientBottom = Color(red: 0.133, green: 0.243, blue: 0.157)
        static let subtitle = Color(red: 0.796, green: 0.871, blue: 0.800)
        static let statLabel = Color(red: 0.718, green: 0.796, blue: 0.729)
    }

    enum Fruits {
        static let tint = Color(white: 0.95)
        static let foreground = Color(red: 0.729, green: 0.459, blue: 0.090)
    }

    enum Vegetables {
        static let tint = Color(white: 0.95)
        static let foreground = Color(red: 0.220, green: 0.478, blue: 0.259)
    }

    enum Handicrafts {
        static let tint = Color(white: 0.95)
        static let foreground = Color(red: 0.047, green: 0.267, blue: 0.486)
    }
}

extension LocalCategory {
    var tint: Color {
        switch self {
        case .all: return LocaliteTheme.surface
        case .fruits: return LocaliteTheme.Fruits.tint
        case .vegetables: return LocaliteTheme.Vegetables.tint
        case .handicrafts: return LocaliteTheme.Handicrafts.tint
        }
    }

    var foreground: Color {
        switch self {
        case .all: return LocaliteTheme.ink
        case .fruits: return LocaliteTheme.Fruits.foreground
        case .vegetables: return LocaliteTheme.Vegetables.foreground
        case .handicrafts: return LocaliteTheme.Handicrafts.foreground
        }
    }
}
