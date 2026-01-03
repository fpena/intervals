//
//  ExerciseStats.swift
//  Intervals
//

import Foundation
import SwiftData

@Model
final class ExerciseStats {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID

    // MARK: - Scope
    var exerciseType: ExerciseType
    var grade: Grade

    // Optional: granular tracking (e.g., stats for "minor 3rd" specifically)
    var subType: String?  // e.g., "m3" for interval, "major" for chord

    // MARK: - Aggregated Stats
    var totalAttempts: Int
    var correctAttempts: Int
    var totalResponseTimeMs: Int  // Sum for calculating average
    var lastAttemptDate: Date?

    // MARK: - Spaced Repetition
    var easeFactor: Double  // SM-2 algorithm: starts at 2.5
    var intervalDays: Int   // Days until next review
    var nextReviewDate: Date?

    // MARK: - Relationship
    var user: UserProfile?

    // MARK: - Initialization
    init(
        exerciseType: ExerciseType,
        grade: Grade,
        subType: String? = nil
    ) {
        self.id = UUID()
        self.exerciseType = exerciseType
        self.grade = grade
        self.subType = subType
        self.totalAttempts = 0
        self.correctAttempts = 0
        self.totalResponseTimeMs = 0
        self.lastAttemptDate = nil
        self.easeFactor = 2.5
        self.intervalDays = 1
        self.nextReviewDate = nil
    }

    // MARK: - Computed Properties
    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctAttempts) / Double(totalAttempts)
    }

    var averageResponseTimeMs: Int {
        guard totalAttempts > 0 else { return 0 }
        return totalResponseTimeMs / totalAttempts
    }

    var masteryLevel: MasteryLevel {
        switch accuracy {
        case 0..<0.4: return .learning
        case 0.4..<0.7: return .practicing
        case 0.7..<0.9: return .familiar
        default: return .mastered
        }
    }
}
