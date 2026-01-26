//
//  DynamicLevel.swift
//  Intervals
//

import SwiftUI

/// Represents musical dynamic levels (volume markings)
enum DynamicLevel: String, CaseIterable, Codable {
    case pp  // Pianissimo - very soft
    case p   // Piano - soft
    case mp  // Mezzo-piano - moderately soft
    case mf  // Mezzo-forte - moderately loud
    case f   // Forte - loud
    case ff  // Fortissimo - very loud

    /// Volume level for playback (0.0 to 1.0)
    var volumeLevel: Float {
        switch self {
        case .pp: return 0.15
        case .p: return 0.30
        case .mp: return 0.45
        case .mf: return 0.60
        case .f: return 0.80
        case .ff: return 1.0
        }
    }

    /// Display name (the Italian abbreviation)
    var displayName: String {
        rawValue
    }

    /// Full Italian name
    var italianName: String {
        switch self {
        case .pp: return "Pianissimo"
        case .p: return "Piano"
        case .mp: return "Mezzo-piano"
        case .mf: return "Mezzo-forte"
        case .f: return "Forte"
        case .ff: return "Fortissimo"
        }
    }

    /// English description
    var englishDescription: String {
        switch self {
        case .pp: return "Very soft"
        case .p: return "Soft"
        case .mp: return "Moderately soft"
        case .mf: return "Moderately loud"
        case .f: return "Loud"
        case .ff: return "Very loud"
        }
    }

    /// SF Symbol icon representing the dynamic level
    var icon: String {
        switch self {
        case .pp: return "speaker.wave.1"
        case .p: return "speaker.wave.1.fill"
        case .mp: return "speaker.wave.2"
        case .mf: return "speaker.wave.2.fill"
        case .f: return "speaker.wave.3"
        case .ff: return "speaker.wave.3.fill"
        }
    }

    /// Color associated with the dynamic level
    var color: Color {
        switch self {
        case .pp: return Color.blue.opacity(0.6)
        case .p: return Color.blue
        case .mp: return Color.green
        case .mf: return Color.yellow
        case .f: return Color.orange
        case .ff: return Color.red
        }
    }

    /// Initialize from a string (for parsing config)
    init?(from string: String) {
        self.init(rawValue: string.lowercased())
    }

    /// Get dynamics from an array of string identifiers
    static func dynamics(from strings: [String]) -> [DynamicLevel] {
        strings.compactMap { DynamicLevel(from: $0) }
    }
}
