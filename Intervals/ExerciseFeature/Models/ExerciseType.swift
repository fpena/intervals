//
//  ExerciseType.swift
//  Intervals
//

import Foundation

enum ExerciseType: String, Codable {
    case intervals
    case chords
    case rhythm
    case melody
}

enum IntervalType: String, CaseIterable, Codable {
    case minorSecond = "Minor 2nd"
    case majorSecond = "Major 2nd"
    case minorThird = "Minor 3rd"
    case majorThird = "Major 3rd"
    case perfectFourth = "Perfect 4th"
    case tritone = "Tritone"
    case perfectFifth = "Perfect 5th"
    case minorSixth = "Minor 6th"
    case majorSixth = "Major 6th"
    case minorSeventh = "Minor 7th"
    case majorSeventh = "Major 7th"
    case octave = "Octave"
}
