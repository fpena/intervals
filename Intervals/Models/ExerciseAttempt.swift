//
//  ExerciseAttempt.swift
//  Intervals
//

import Foundation
import SwiftData

@Model
final class ExerciseAttempt {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID

    // MARK: - Exercise Details
    var exerciseType: ExerciseType
    var grade: Grade

    // MARK: - Question & Answer
    // Store as JSON-encoded strings for flexibility across exercise types
    var questionData: String  // JSON: what was asked (e.g., {"interval": "M3", "rootNote": "C4"})
    var correctAnswer: String // JSON: the correct answer
    var userAnswer: String    // JSON: what the user selected

    // MARK: - Result
    var isCorrect: Bool
    var responseTimeMs: Int  // Milliseconds to answer
    var xpEarned: Int

    // MARK: - Metadata
    var timestamp: Date
    var sessionId: UUID?  // Groups attempts in a single practice session

    // MARK: - Relationship
    var user: UserProfile?

    // MARK: - Initialization
    init(
        exerciseType: ExerciseType,
        grade: Grade,
        questionData: String,
        correctAnswer: String,
        userAnswer: String,
        isCorrect: Bool,
        responseTimeMs: Int,
        xpEarned: Int,
        sessionId: UUID? = nil
    ) {
        self.id = UUID()
        self.exerciseType = exerciseType
        self.grade = grade
        self.questionData = questionData
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.responseTimeMs = responseTimeMs
        self.xpEarned = xpEarned
        self.timestamp = Date()
        self.sessionId = sessionId
    }
}
