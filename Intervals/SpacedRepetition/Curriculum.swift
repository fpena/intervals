//
//  Curriculum.swift
//  Intervals
//

import Foundation

/// Defines what content is available at each grade level
struct Curriculum {

    // MARK: - SubTypes by Grade

    static func subTypes(for exerciseType: ExerciseType, grade: Grade) -> [String] {
        switch exerciseType {
        case .intervals:
            return intervalsForGrade(grade)
        case .chords:
            return chordsForGrade(grade)
        case .cadences:
            return cadencesForGrade(grade)
        default:
            return []
        }
    }

    // MARK: - Intervals

    private static func intervalsForGrade(_ grade: Grade) -> [String] {
        switch grade {
        case .initial:
            // Major 2nd, Major 3rd, Perfect 4th, Perfect 5th
            return ["Major 2nd", "Major 3rd", "Perfect 4th", "Perfect 5th"]

        case .grade1:
            // Add minor 2nd, minor 3rd
            return ["Minor 2nd", "Major 2nd", "Minor 3rd", "Major 3rd", "Perfect 4th", "Perfect 5th"]

        case .grade2:
            // Add major 6th, octave
            return ["Minor 2nd", "Major 2nd", "Minor 3rd", "Major 3rd", "Perfect 4th", "Perfect 5th", "Major 6th", "Octave"]

        case .grade3:
            // Add minor 6th, major/minor 7th
            return ["Minor 2nd", "Major 2nd", "Minor 3rd", "Major 3rd", "Perfect 4th", "Perfect 5th",
                    "Minor 6th", "Major 6th", "Minor 7th", "Major 7th", "Octave"]

        case .grade4, .grade5, .grade6, .grade7, .grade8:
            // All intervals including tritone
            return IntervalType.allCases.map { $0.displayName }
        }
    }

    // MARK: - Chords

    private static func chordsForGrade(_ grade: Grade) -> [String] {
        switch grade {
        case .initial:
            return []  // No chords at Initial

        case .grade1, .grade2:
            return ["Major", "Minor"]

        case .grade3:
            return ["Major", "Minor", "Diminished", "Augmented"]

        case .grade4, .grade5:
            return ["Major", "Minor", "Diminished", "Augmented", "Dominant 7th"]

        case .grade6, .grade7, .grade8:
            return ChordType.allCases.map { $0.displayName }
        }
    }

    // MARK: - Cadences

    private static func cadencesForGrade(_ grade: Grade) -> [String] {
        switch grade {
        case .initial, .grade1, .grade2, .grade3:
            return []  // No cadences before Grade 4

        case .grade4:
            return ["Perfect", "Plagal"]

        case .grade5, .grade6, .grade7, .grade8:
            return CadenceType.allCases.map { $0.displayName }
        }
    }

    // MARK: - Difficulty Ordering

    /// Returns relative difficulty (lower = easier)
    static func difficulty(of subType: String) -> Int {
        // Intervals ordered by typical learning difficulty
        let intervalOrder = ["Perfect 5th", "Perfect 4th", "Major 3rd", "Minor 3rd",
                            "Major 2nd", "Minor 2nd", "Octave", "Major 6th",
                            "Minor 6th", "Major 7th", "Minor 7th", "Tritone"]
        if let index = intervalOrder.firstIndex(of: subType) {
            return index
        }

        // Chords
        let chordOrder = ["Major", "Minor", "Diminished", "Augmented",
                         "Dominant 7th", "Major 7th", "Minor 7th"]
        if let index = chordOrder.firstIndex(of: subType) {
            return index
        }

        // Cadences
        let cadenceOrder = ["Perfect", "Plagal", "Imperfect", "Interrupted"]
        if let index = cadenceOrder.firstIndex(of: subType) {
            return index
        }

        return 100  // Unknown items go last
    }

    // MARK: - Exercise Type Availability

    /// Check if an exercise type is available for a grade
    static func isExerciseTypeAvailable(_ exerciseType: ExerciseType, for grade: Grade) -> Bool {
        return !subTypes(for: exerciseType, grade: grade).isEmpty
    }

    /// Get all available exercise types for a grade
    static func availableExerciseTypes(for grade: Grade) -> [ExerciseType] {
        ExerciseType.allCases.filter { isExerciseTypeAvailable($0, for: grade) }
    }
}
