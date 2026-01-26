//
//  CompletedExercise.swift
//  Intervals
//
//  Tracks user completion of specific exercises from Convex.
//

import Foundation
import SwiftData

@Model
final class CompletedExercise {
    // MARK: - Identity

    @Attribute(.unique) var id: UUID

    /// The Convex exercise ID (matches Exercise._id)
    var exerciseId: String

    /// The Convex chapter ID for grouping
    var chapterId: String

    // MARK: - Best Performance

    /// Best score achieved (0-100)
    var bestScore: Int

    /// Best streak achieved in a session
    var bestStreak: Int

    /// Total XP earned from this exercise across all attempts
    var totalXpEarned: Int

    // MARK: - Attempt Tracking

    /// Number of times this exercise was completed
    var completionCount: Int

    /// Number of times this exercise was attempted (including failures)
    var attemptCount: Int

    // MARK: - Timestamps

    /// When this exercise was first completed
    var firstCompletedAt: Date

    /// When this exercise was last completed
    var lastCompletedAt: Date

    /// When this exercise was last attempted
    var lastAttemptedAt: Date

    // MARK: - Relationship

    var user: UserProfile?

    // MARK: - Initialization

    init(
        exerciseId: String,
        chapterId: String,
        score: Int,
        streak: Int,
        xpEarned: Int
    ) {
        self.id = UUID()
        self.exerciseId = exerciseId
        self.chapterId = chapterId
        self.bestScore = score
        self.bestStreak = streak
        self.totalXpEarned = xpEarned
        self.completionCount = 1
        self.attemptCount = 1
        self.firstCompletedAt = Date()
        self.lastCompletedAt = Date()
        self.lastAttemptedAt = Date()
    }

    // MARK: - Computed Properties

    /// Whether the user has passed this exercise at least once
    var isPassed: Bool {
        completionCount > 0
    }

    /// Star rating based on best score (0-3)
    var starRating: Int {
        switch bestScore {
        case 90...100: return 3
        case 70..<90: return 2
        case 50..<70: return 1
        default: return 0
        }
    }

    // MARK: - Update Methods

    /// Update stats after a new attempt
    func recordAttempt(score: Int, streak: Int, xpEarned: Int, passed: Bool) {
        attemptCount += 1
        lastAttemptedAt = Date()

        if passed {
            completionCount += 1
            lastCompletedAt = Date()
            totalXpEarned += xpEarned

            // Update bests
            if score > bestScore {
                bestScore = score
            }
            if streak > bestStreak {
                bestStreak = streak
            }
        }
    }
}

// MARK: - Exercise Progress Status

enum ExerciseProgressStatus {
    case notStarted
    case attempted
    case completed(stars: Int)

    var icon: String {
        switch self {
        case .notStarted:
            return "circle"
        case .attempted:
            return "circle.dotted"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
}
