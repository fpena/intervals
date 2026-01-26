//
//  DynamicsQuestion.swift
//  Intervals
//

import Foundation

/// Represents a single dynamics recognition question
struct DynamicsQuestion: Identifiable {
    let id = UUID()

    /// MIDI notes for the chord (typically a major triad)
    let chordNotes: [Int]

    /// The correct dynamic level for this question
    let correctAnswer: DynamicLevel

    /// Volume level computed from the correct answer
    var volume: Float {
        correctAnswer.volumeLevel
    }
}
