//
//  Enums.swift
//  Intervals
//

import Foundation

// ABRSM grades from Initial to Grade 8
enum Grade: Int, Codable, CaseIterable {
    case initial = 0
    case grade1 = 1
    case grade2 = 2
    case grade3 = 3
    case grade4 = 4
    case grade5 = 5
    case grade6 = 6
    case grade7 = 7
    case grade8 = 8

    var displayName: String {
        switch self {
        case .initial: return "Initial"
        default: return "Grade \(rawValue)"
        }
    }
}

// Types of exercises available in the app
enum ExerciseType: String, Codable, CaseIterable {
    case intervals          // Identify interval between two notes
    case chords             // Identify chord type (major, minor, etc.)
    case cadences           // Identify cadence type (perfect, plagal, etc.)
    case rhythmClapping     // Clap back a rhythm pattern
    case melodyPlayback     // Sing or play back a melody
    case sightSinging       // Sing from notation
    case musicalFeatures    // Identify dynamics, articulation, tempo changes

    var displayName: String {
        switch self {
        case .intervals: return "Intervals"
        case .chords: return "Chords"
        case .cadences: return "Cadences"
        case .rhythmClapping: return "Rhythm"
        case .melodyPlayback: return "Melody Playback"
        case .sightSinging: return "Sight Singing"
        case .musicalFeatures: return "Musical Features"
        }
    }

    // Which grades include this exercise type
    var availableFromGrade: Grade {
        switch self {
        case .intervals: return .initial
        case .chords: return .grade1
        case .cadences: return .grade4
        case .rhythmClapping: return .initial
        case .melodyPlayback: return .initial
        case .sightSinging: return .grade1
        case .musicalFeatures: return .grade3
        }
    }
}

// Interval types for interval exercises
enum IntervalType: String, Codable, CaseIterable {
    case unison = "P1"
    case minorSecond = "m2"
    case majorSecond = "M2"
    case minorThird = "m3"
    case majorThird = "M3"
    case perfectFourth = "P4"
    case tritone = "TT"
    case perfectFifth = "P5"
    case minorSixth = "m6"
    case majorSixth = "M6"
    case minorSeventh = "m7"
    case majorSeventh = "M7"
    case octave = "P8"

    var displayName: String {
        switch self {
        case .unison: return "Unison"
        case .minorSecond: return "Minor 2nd"
        case .majorSecond: return "Major 2nd"
        case .minorThird: return "Minor 3rd"
        case .majorThird: return "Major 3rd"
        case .perfectFourth: return "Perfect 4th"
        case .tritone: return "Tritone"
        case .perfectFifth: return "Perfect 5th"
        case .minorSixth: return "Minor 6th"
        case .majorSixth: return "Major 6th"
        case .minorSeventh: return "Minor 7th"
        case .majorSeventh: return "Major 7th"
        case .octave: return "Octave"
        }
    }

    var semitones: Int {
        switch self {
        case .unison: return 0
        case .minorSecond: return 1
        case .majorSecond: return 2
        case .minorThird: return 3
        case .majorThird: return 4
        case .perfectFourth: return 5
        case .tritone: return 6
        case .perfectFifth: return 7
        case .minorSixth: return 8
        case .majorSixth: return 9
        case .minorSeventh: return 10
        case .majorSeventh: return 11
        case .octave: return 12
        }
    }
}

// Chord types for chord exercises
enum ChordType: String, Codable, CaseIterable {
    case major
    case minor
    case augmented
    case diminished
    case majorSeventh = "maj7"
    case minorSeventh = "min7"
    case dominantSeventh = "dom7"

    var displayName: String {
        switch self {
        case .major: return "Major"
        case .minor: return "Minor"
        case .augmented: return "Augmented"
        case .diminished: return "Diminished"
        case .majorSeventh: return "Major 7th"
        case .minorSeventh: return "Minor 7th"
        case .dominantSeventh: return "Dominant 7th"
        }
    }
}

// Cadence types for cadence exercises
enum CadenceType: String, Codable, CaseIterable {
    case perfect        // V-I
    case plagal         // IV-I
    case imperfect      // I-V, II-V, IV-V
    case interrupted    // V-VI

    var displayName: String {
        switch self {
        case .perfect: return "Perfect"
        case .plagal: return "Plagal"
        case .imperfect: return "Imperfect"
        case .interrupted: return "Interrupted"
        }
    }
}

// Subscription tiers
enum SubscriptionType: String, Codable {
    case free
    case individual
    case family
}

// Instrument sounds available
enum InstrumentType: String, Codable, CaseIterable {
    case piano
    case guitar
    case violin
    case flute
    case clarinet

    var displayName: String {
        rawValue.capitalized
    }
}

// Mastery levels for exercise stats
enum MasteryLevel: String, Codable {
    case learning
    case practicing
    case familiar
    case mastered

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {  // SwiftUI color name
        switch self {
        case .learning: return "red"
        case .practicing: return "orange"
        case .familiar: return "yellow"
        case .mastered: return "green"
        }
    }
}
