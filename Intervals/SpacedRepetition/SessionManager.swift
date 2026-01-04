//
//  SessionManager.swift
//  Intervals
//

import Foundation
import SwiftData
import Combine

/// Manages a practice session with dynamic adjustments based on real-time performance
@MainActor
class SessionManager: ObservableObject {
    @Published var currentExercise: PlannedExercise?
    @Published var sessionProgress: Double = 0
    @Published var isSessionComplete: Bool = false

    private(set) var plan: SessionPlan
    private var exerciseIndex = 0
    private var recentCorrect: [Bool] = []  // Last 5 attempts

    private let modelContext: ModelContext
    private let user: UserProfile
    private let algorithm: SpacedRepetitionAlgorithm

    var totalExercises: Int {
        plan.exercises.count
    }

    var currentExerciseNumber: Int {
        exerciseIndex + 1
    }

    var correctCount: Int {
        recentCorrect.filter { $0 }.count
    }

    init(
        plan: SessionPlan,
        modelContext: ModelContext,
        user: UserProfile,
        algorithm: SpacedRepetitionAlgorithm = SpacedRepetitionAlgorithm()
    ) {
        self.plan = plan
        self.modelContext = modelContext
        self.user = user
        self.algorithm = algorithm
        self.currentExercise = plan.exercises.first
    }

    /// Record an attempt and advance to next exercise
    func recordAttempt(
        isCorrect: Bool,
        responseTimeMs: Int,
        correctAnswer: String,
        userAnswer: String
    ) {
        guard let current = currentExercise else { return }

        // Track recent performance
        recentCorrect.append(isCorrect)
        if recentCorrect.count > 5 {
            recentCorrect.removeFirst()
        }

        // Calculate response quality
        let quality = ResponseQuality.calculate(
            isCorrect: isCorrect,
            responseTimeMs: responseTimeMs,
            correctAnswer: correctAnswer,
            userAnswer: userAnswer
        )

        // Update stats for this subType
        updateStats(for: current, quality: quality, responseTimeMs: responseTimeMs, isCorrect: isCorrect)

        // Advance to next exercise
        exerciseIndex += 1

        // Dynamic adjustments
        if shouldInjectChallenge() {
            injectChallengeExercise()
        } else if shouldInjectReinforcement() {
            injectReinforcementExercise()
        }

        // Update current exercise
        if exerciseIndex < plan.exercises.count {
            currentExercise = plan.exercises[exerciseIndex]
        } else {
            currentExercise = nil
            isSessionComplete = true
        }

        sessionProgress = Double(exerciseIndex) / Double(plan.exercises.count)
    }

    /// Skip to next exercise without recording
    func skipExercise() {
        exerciseIndex += 1

        if exerciseIndex < plan.exercises.count {
            currentExercise = plan.exercises[exerciseIndex]
        } else {
            currentExercise = nil
            isSessionComplete = true
        }

        sessionProgress = Double(exerciseIndex) / Double(plan.exercises.count)
    }

    // MARK: - Stats Update

    private func updateStats(
        for exercise: PlannedExercise,
        quality: ResponseQuality,
        responseTimeMs: Int,
        isCorrect: Bool
    ) {
        // Find or create stats for this exercise subType
        let existingStats = user.stats.first {
            $0.exerciseType == exercise.exerciseType &&
            $0.grade == user.currentGrade &&
            $0.subType == exercise.subType
        }

        let stats: ExerciseStats
        if let existing = existingStats {
            stats = existing
        } else {
            stats = ExerciseStats(
                exerciseType: exercise.exerciseType,
                grade: user.currentGrade,
                subType: exercise.subType
            )
            stats.user = user
            modelContext.insert(stats)
        }

        // Update attempt counts
        stats.totalAttempts += 1
        if isCorrect {
            stats.correctAttempts += 1
        }
        stats.totalResponseTimeMs += responseTimeMs
        stats.lastAttemptDate = Date()

        // Update spaced repetition data
        var srData = SpacedRepetitionData(
            easeFactor: stats.easeFactor,
            intervalDays: Double(stats.intervalDays),
            nextReviewDate: stats.nextReviewDate,
            consecutiveCorrect: isCorrect ? 1 : 0, // Simplified tracking
            state: determineItemState(for: stats),
            lapseCount: 0
        )

        algorithm.updateSpacedRepetition(data: &srData, quality: quality)

        // Write back to stats
        stats.easeFactor = srData.easeFactor
        stats.intervalDays = Int(srData.intervalDays)
        stats.nextReviewDate = srData.nextReviewDate

        try? modelContext.save()
    }

    private func determineItemState(for stats: ExerciseStats) -> ItemState {
        if stats.totalAttempts == 0 {
            return .new
        } else if stats.totalAttempts < 10 || stats.accuracy < 0.6 {
            return .learning
        } else if stats.accuracy >= 0.9 && stats.intervalDays >= 21 {
            return .mastered
        } else {
            return .reviewing
        }
    }

    // MARK: - Dynamic Adjustments

    private func shouldInjectChallenge() -> Bool {
        // If user got last 5 correct, inject a challenge
        return recentCorrect.count >= 5 && recentCorrect.allSatisfy { $0 }
    }

    private func shouldInjectReinforcement() -> Bool {
        // If user got last 3 wrong, inject an easy win
        let lastThree = recentCorrect.suffix(3)
        return lastThree.count >= 3 && lastThree.allSatisfy { !$0 }
    }

    private func injectChallengeExercise() {
        guard let current = currentExercise else { return }

        let challenge = PlannedExercise(
            exerciseType: current.exerciseType,
            subType: current.subType,
            difficulty: DifficultyLevel(rawValue: min(4, current.difficulty.rawValue + 1)) ?? .expert,
            category: .challenge
        )

        plan.exercises.insert(challenge, at: exerciseIndex)
        recentCorrect.removeAll()  // Reset after injection
    }

    private func injectReinforcementExercise() {
        // Find an easy exercise from user's best-performing items
        let masteredItems = user.stats.filter {
            $0.accuracy >= 0.9 && $0.totalAttempts >= 10
        }

        if let bestItem = masteredItems.randomElement() {
            let reinforcement = PlannedExercise(
                exerciseType: bestItem.exerciseType,
                subType: bestItem.subType ?? "",
                difficulty: .easy,
                category: .reinforcement
            )

            plan.exercises.insert(reinforcement, at: exerciseIndex)
        }

        recentCorrect.removeAll()
    }

    // MARK: - Session Summary

    func getSessionSummary() -> SessionSummary {
        let totalAttempts = recentCorrect.count
        let correctAttempts = recentCorrect.filter { $0 }.count

        return SessionSummary(
            totalExercises: plan.exercises.count,
            completedExercises: exerciseIndex,
            correctAnswers: correctAttempts,
            accuracy: totalAttempts > 0 ? Double(correctAttempts) / Double(totalAttempts) : 0,
            newItemsIntroduced: plan.newItemsCount,
            reviewsCompleted: plan.reviewItemsCount
        )
    }
}

// MARK: - Session Summary

struct SessionSummary {
    let totalExercises: Int
    let completedExercises: Int
    let correctAnswers: Int
    let accuracy: Double
    let newItemsIntroduced: Int
    let reviewsCompleted: Int

    var completionPercentage: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(completedExercises) / Double(totalExercises)
    }
}
