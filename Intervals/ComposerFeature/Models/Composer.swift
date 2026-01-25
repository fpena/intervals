//
//  Composer.swift
//  Intervals
//
//  Created by Felipe Pena on 2026-01-25.
//

import Foundation
import SwiftUI

struct Composer: Identifiable, Codable, Equatable {
    let _id: String
    let accessTier: String
    let birthYear: Double
    let childFriendlyName: String
    let deathYear: Double
    let era: String
    let freePreviewExercises: Double
    let illustrationStorageId: String
    let isActive: Bool
    let name: String
    let shortBio: String
    let slug: String
    let sortOrder: Double
    let themePrimaryColor: String
    let themeSecondaryColor: String

    var id: String { _id }

    var primaryColor: Color {
        Color(hex: themePrimaryColor) ?? .blue
    }

    var secondaryColor: Color {
        Color(hex: themeSecondaryColor) ?? .purple
    }

    var lifespan: String {
        "\(Int(birthYear)) - \(Int(deathYear))"
    }

    var isFree: Bool {
        accessTier == "free"
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let length = hexSanitized.count

        if length == 6 {
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        } else if length == 8 {
            self.init(
                red: Double((rgb & 0xFF000000) >> 24) / 255.0,
                green: Double((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: Double((rgb & 0x0000FF00) >> 8) / 255.0,
                opacity: Double(rgb & 0x000000FF) / 255.0
            )
        } else {
            return nil
        }
    }
}

