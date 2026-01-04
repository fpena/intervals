//
//  SessionTypes.swift
//  Intervals
//

import Foundation

// MARK: - Session Configuration

struct SessionConfig {
    let targetDurationMinutes: Int    // From user's daily goal
    let exerciseTypes: [ExerciseType] // Which types to include
    let grade: Grade                  // Current grade

    /// Estimated exercise count based on ~15 seconds per exercise
    var estimatedExerciseCount: Int {
        (targetDurationMinutes * 60) / 15
    }

    init(
        targetDurationMinutes: Int = 10,
        exerciseTypes: [ExerciseType] = [.intervals],
        grade: Grade = .initial
    ) {
        self.targetDurationMinutes = targetDurationMinutes
        self.exerciseTypes = exerciseTypes
        self.grade = grade
    }
}

// MARK: - Session Plan

struct SessionPlan {
    var exercises: [PlannedExercise]
    var newItemsCount: Int
    var reviewItemsCount: Int
    var learningItemsCount: Int
    var reinforcementCount: Int

    var totalCount: Int {
        exercises.count
    }

    var isEmpty: Bool {
        exercises.isEmpty
    }
}

// MARK: - Planned Exercise

struct PlannedExercise: Identifiable {
    let id: UUID
    let exerciseType: ExerciseType
    let subType: String           // e.g., "Major 3rd" for major third
    let difficulty: DifficultyLevel
    let category: ExerciseCategory

    init(
        id: UUID = UUID(),
        exerciseType: ExerciseType,
        subType: String,
        difficulty: DifficultyLevel,
        category: ExerciseCategory
    ) {
        self.id = id
        self.exerciseType = exerciseType
        self.subType = subType
        self.difficulty = difficulty
        self.category = category
    }
}

// MARK: - Session Composition

struct SessionComposition {
    // Target percentages (flexible based on availability)
    static let targetNew: Double = 0.15         // 15% new items
    static let targetLearning: Double = 0.25    // 25% items in learning phase
    static let targetReview: Double = 0.40      // 40% due reviews
    static let targetReinforcement: Double = 0.15  // 15% confidence builders
    static let targetChallenge: Double = 0.05   // 5% stretch items

    // Constraints
    static let maxNewPerSession = 5             // Don't overwhelm with new material
    static let maxConsecutiveSameType = 3       // Variety
    static let minCorrectBeforeNew = 2          // Build confidence before introducing new
}
