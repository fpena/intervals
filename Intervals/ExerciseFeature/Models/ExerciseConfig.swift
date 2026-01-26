//
//  ExerciseConfig.swift
//  Intervals
//

import Foundation

// MARK: - Pitch Direction Config

struct PitchDirectionConfig: Codable {
    let minIntervalSemitones: Int
    let maxIntervalSemitones: Int
    let noteRangeLow: String
    let noteRangeHigh: String
    let numQuestions: Int

    /// Parse from JSON string stored in Exercise.config
    static func parse(from jsonString: String) -> PitchDirectionConfig? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(PitchDirectionConfig.self, from: data)
    }

    /// Default config for pitch direction exercises
    static let defaultConfig = PitchDirectionConfig(
        minIntervalSemitones: 7,
        maxIntervalSemitones: 12,
        noteRangeLow: "C4",
        noteRangeHigh: "C6",
        numQuestions: 5
    )
}

// MARK: - Dynamics Config

struct DynamicsConfig: Codable {
    let recognitionMode: String  // "static" or "change"
    let allowedDynamics: [String]  // ["f", "mf", "p"] or ["crescendo", "diminuendo"]
    let numQuestions: Int
    let chordType: String?  // Optional: "major", "minor", etc.
    let noteRangeLow: String?  // Optional: e.g., "C3"
    let noteRangeHigh: String?  // Optional: e.g., "C5"

    static func parse(from jsonString: String) -> DynamicsConfig? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(DynamicsConfig.self, from: data)
    }

    static let defaultConfig = DynamicsConfig(
        recognitionMode: "static",
        allowedDynamics: ["pp", "p", "mp", "mf", "f", "ff"],
        numQuestions: 5,
        chordType: "major",
        noteRangeLow: "C3",
        noteRangeHigh: "C5"
    )
}

// MARK: - Mixed Challenge Config

struct MixedChallengeConfig: Codable {
    let exerciseTypes: [String]
    let numQuestions: Int
    let randomOrder: Bool

    static func parse(from jsonString: String) -> MixedChallengeConfig? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(MixedChallengeConfig.self, from: data)
    }

    static let defaultConfig = MixedChallengeConfig(
        exerciseTypes: ["pitch_direction", "dynamics"],
        numQuestions: 8,
        randomOrder: true
    )
}

// MARK: - Note Parsing Utilities

enum NoteParsing {
    /// Convert scientific pitch notation (e.g., "C4") to MIDI note number
    static func midiNote(from notation: String) -> Int? {
        let noteNames: [String: Int] = [
            "C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11
        ]

        guard notation.count >= 2 else { return nil }

        let note = String(notation.prefix(1)).uppercased()
        var remaining = String(notation.dropFirst())

        // Handle sharps and flats
        var semitoneOffset = 0
        if remaining.hasPrefix("#") {
            semitoneOffset = 1
            remaining = String(remaining.dropFirst())
        } else if remaining.hasPrefix("b") {
            semitoneOffset = -1
            remaining = String(remaining.dropFirst())
        }

        guard let baseNote = noteNames[note],
              let octave = Int(remaining) else { return nil }

        // MIDI note: C4 = 60
        return (octave + 1) * 12 + baseNote + semitoneOffset
    }

    /// Convert MIDI note number to scientific pitch notation
    static func notation(from midiNote: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let octave = (midiNote / 12) - 1
        let noteIndex = midiNote % 12
        return "\(noteNames[noteIndex])\(octave)"
    }
}
