//
//  SpacedRepetitionTypes.swift
//  Intervals
//

import Foundation

// MARK: - Item State

/// Represents the learning state of a trackable item (SubType)
enum ItemState: String, Codable {
    case new          // Never attempted
    case learning     // Recently introduced, needs frequent review
    case reviewing    // In spaced repetition cycle
    case mastered     // High accuracy, long intervals
    case lapsed       // Was mastered, accuracy dropped
}

// MARK: - Response Quality

/// Quality score for spaced repetition algorithm (0-5 scale)
enum ResponseQuality: Int, Codable {
    case completeBlackout = 0    // No idea, random guess
    case incorrect = 1           // Wrong answer
    case incorrectButClose = 2   // Wrong but adjacent interval/chord
    case correctWithDifficulty = 3  // Correct but slow (>5 seconds)
    case correct = 4             // Correct with good speed (2-5 seconds)
    case perfectInstant = 5      // Correct and fast (<2 seconds)
}

// MARK: - Difficulty Level

enum DifficultyLevel: Int, Codable, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3
    case expert = 4

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
}

// MARK: - Exercise Category

/// Category of exercise in a session
enum ExerciseCategory: String, Codable {
    case new           // Never seen before
    case learning      // Recently introduced
    case review        // Due for spaced repetition review
    case reinforcement // Recently correct, shown for confidence
    case challenge     // Slightly above current level (stretch)
}

// MARK: - Difficulty Profile

struct DifficultyProfile: Codable {
    var direction: Int          // 0-2 (ascending only, both, harmonic)
    var range: Int              // 0-2 (within octave, to 10th, 2 octaves)
    var register: Int           // 0-2 (middle, full, extreme)
    var tempo: Int              // 0-2 (slow, medium, fast)
    var repetitions: Int        // 0-2 (3x, 2x, 1x - inverse: 2 = only 1 play)

    var totalScore: Int {
        direction + range + register + tempo + repetitions
    }

    var level: DifficultyLevel {
        switch totalScore {
        case 0...3: return .easy
        case 4...6: return .medium
        case 7...8: return .hard
        default: return .expert
        }
    }

    static var easy: DifficultyProfile {
        DifficultyProfile(direction: 0, range: 0, register: 0, tempo: 0, repetitions: 0)
    }

    static var medium: DifficultyProfile {
        DifficultyProfile(direction: 1, range: 1, register: 1, tempo: 1, repetitions: 1)
    }

    static var hard: DifficultyProfile {
        DifficultyProfile(direction: 2, range: 2, register: 1, tempo: 2, repetitions: 2)
    }
}

// MARK: - Spaced Repetition Data

struct SpacedRepetitionData: Codable {
    var easeFactor: Double      // Multiplier for interval growth (1.3 - 2.5)
    var intervalDays: Double    // Days until next review
    var nextReviewDate: Date?   // Scheduled review date
    var consecutiveCorrect: Int // Streak of correct answers
    var state: ItemState        // Current learning state
    var lapseCount: Int         // Times fallen from mastered/reviewing to learning

    /// Initial values for new items
    static var initial: SpacedRepetitionData {
        SpacedRepetitionData(
            easeFactor: 2.5,
            intervalDays: 0,
            nextReviewDate: nil,
            consecutiveCorrect: 0,
            state: .new,
            lapseCount: 0
        )
    }
}

// MARK: - Response Quality Calculation

extension ResponseQuality {
    /// Calculate quality score based on attempt results
    static func calculate(
        isCorrect: Bool,
        responseTimeMs: Int,
        correctAnswer: String,
        userAnswer: String
    ) -> ResponseQuality {
        if !isCorrect {
            // Check if answer was "close" (e.g., m3 vs M3, or off by one semitone)
            let isClose = Self.isCloseAnswer(correct: correctAnswer, given: userAnswer)
            return isClose ? .incorrectButClose : .incorrect
        }

        // Correct answer - evaluate speed
        switch responseTimeMs {
        case 0..<2000:
            return .perfectInstant
        case 2000..<5000:
            return .correct
        default:
            return .correctWithDifficulty
        }
    }

    /// Check if the given answer is close to the correct answer
    private static func isCloseAnswer(correct: String, given: String) -> Bool {
        // For intervals: adjacent intervals are "close"
        guard let correctInterval = IntervalType.allCases.first(where: { $0.displayName == correct }),
              let givenInterval = IntervalType.allCases.first(where: { $0.displayName == given }) else {
            return false
        }
        return abs(correctInterval.semitones - givenInterval.semitones) <= 1
    }
}
