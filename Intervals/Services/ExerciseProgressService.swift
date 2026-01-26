//
//  ExerciseProgressService.swift
//  Intervals
//
//  Service for tracking exercise completion and progress.
//

import Foundation
import SwiftData

@MainActor
final class ExerciseProgressService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Record Completion

    /// Record an exercise completion
    func recordCompletion(
        user: UserProfile,
        exerciseId: String,
        chapterId: String,
        score: Int,
        streak: Int,
        xpEarned: Int,
        passingScore: Int
    ) {
        let passed = score >= passingScore

        // Check if we already have a record for this exercise
        if let existing = user.completedExercises.first(where: { $0.exerciseId == exerciseId }) {
            existing.recordAttempt(score: score, streak: streak, xpEarned: xpEarned, passed: passed)
        } else if passed {
            // Only create record if passed (first completion)
            let completion = CompletedExercise(
                exerciseId: exerciseId,
                chapterId: chapterId,
                score: score,
                streak: streak,
                xpEarned: xpEarned
            )
            completion.user = user
            modelContext.insert(completion)
        }

        // Update user XP
        if passed {
            user.totalXP += xpEarned
            user.updatedAt = Date()
        }

        try? modelContext.save()
    }

    // MARK: - Query Methods

    /// Get completion status for a specific exercise
    func getProgress(for exerciseId: String, user: UserProfile) -> CompletedExercise? {
        user.completedExercises.first { $0.exerciseId == exerciseId }
    }

    /// Get progress status for display
    func getProgressStatus(for exerciseId: String, user: UserProfile) -> ExerciseProgressStatus {
        guard let progress = getProgress(for: exerciseId, user: user) else {
            return .notStarted
        }

        if progress.completionCount > 0 {
            return .completed(stars: progress.starRating)
        } else {
            return .attempted
        }
    }

    /// Get all completed exercises for a chapter
    func getCompletedExercises(forChapter chapterId: String, user: UserProfile) -> [CompletedExercise] {
        user.completedExercises.filter { $0.chapterId == chapterId }
    }

    /// Get completion count for a chapter
    func getChapterCompletionCount(chapterId: String, user: UserProfile) -> Int {
        user.completedExercises.filter { $0.chapterId == chapterId && $0.completionCount > 0 }.count
    }

    /// Check if all exercises in a chapter are completed
    func isChapterComplete(chapterId: String, totalExercises: Int, user: UserProfile) -> Bool {
        getChapterCompletionCount(chapterId: chapterId, user: user) >= totalExercises
    }

    /// Get total stars earned in a chapter
    func getChapterStars(chapterId: String, user: UserProfile) -> Int {
        user.completedExercises
            .filter { $0.chapterId == chapterId }
            .reduce(0) { $0 + $1.starRating }
    }

    /// Get total XP earned from exercises
    func getTotalExerciseXP(user: UserProfile) -> Int {
        user.completedExercises.reduce(0) { $0 + $1.totalXpEarned }
    }
}
