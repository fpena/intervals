//
//  SessionBuilder.swift
//  Intervals
//

import Foundation
import SwiftData

/// Builds a practice session based on user progress and spaced repetition
@MainActor
class SessionBuilder {
    private let modelContext: ModelContext
    private let user: UserProfile
    private let config: SessionConfig
    private let algorithm: SpacedRepetitionAlgorithm

    init(
        modelContext: ModelContext,
        user: UserProfile,
        config: SessionConfig,
        algorithm: SpacedRepetitionAlgorithm = SpacedRepetitionAlgorithm()
    ) {
        self.modelContext = modelContext
        self.user = user
        self.config = config
        self.algorithm = algorithm
    }

    func buildSession() -> SessionPlan {
        let targetCount = config.estimatedExerciseCount

        // 1. Gather candidates from each category
        let dueReviews = gatherDueReviews()
        let learningItems = gatherLearningItems()
        let newItems = gatherNewItems()
        let reinforcementItems = gatherReinforcementItems()

        // 2. Calculate actual counts based on availability
        let composition = calculateComposition(
            targetCount: targetCount,
            available: (
                reviews: dueReviews.count,
                learning: learningItems.count,
                new: newItems.count,
                reinforcement: reinforcementItems.count
            )
        )

        // 3. Select items from each category
        let selectedNew = Array(newItems.prefix(composition.new))
        let selectedLearning = Array(learningItems.prefix(composition.learning))
        let selectedReviews = Array(dueReviews.prefix(composition.reviews))
        let selectedReinforcement = Array(reinforcementItems.prefix(composition.reinforcement))

        // 4. Interleave items using smart ordering
        let exercises = interleaveExercises(
            new: selectedNew,
            learning: selectedLearning,
            reviews: selectedReviews,
            reinforcement: selectedReinforcement
        )

        return SessionPlan(
            exercises: exercises,
            newItemsCount: selectedNew.count,
            reviewItemsCount: selectedReviews.count,
            learningItemsCount: selectedLearning.count,
            reinforcementCount: selectedReinforcement.count
        )
    }

    // MARK: - Gathering Candidates

    private func gatherDueReviews() -> [PlannedExercise] {
        let now = Date()

        return user.stats
            .filter { stats in
                // Is this item due for review?
                guard let nextReview = stats.nextReviewDate else { return false }
                guard config.exerciseTypes.contains(stats.exerciseType) else { return false }
                guard stats.grade == config.grade else { return false }
                return nextReview <= now
            }
            .sorted { a, b in
                // Priority: more overdue first, then lower accuracy
                let aOverdue = a.nextReviewDate.map { now.timeIntervalSince($0) } ?? 0
                let bOverdue = b.nextReviewDate.map { now.timeIntervalSince($0) } ?? 0
                if abs(aOverdue - bOverdue) > 3600 { // More than 1 hour difference
                    return aOverdue > bOverdue
                }
                return a.accuracy < b.accuracy
            }
            .map { stats in
                PlannedExercise(
                    exerciseType: stats.exerciseType,
                    subType: stats.subType ?? "",
                    difficulty: calculateTargetDifficulty(for: stats),
                    category: .review
                )
            }
    }

    private func gatherLearningItems() -> [PlannedExercise] {
        return user.stats
            .filter { stats in
                guard config.exerciseTypes.contains(stats.exerciseType) else { return false }
                guard stats.grade == config.grade else { return false }
                // Items with few attempts or low accuracy are "learning"
                return stats.totalAttempts < 10 || stats.accuracy < 0.6
            }
            .sorted { $0.accuracy < $1.accuracy }
            .map { stats in
                PlannedExercise(
                    exerciseType: stats.exerciseType,
                    subType: stats.subType ?? "",
                    difficulty: .easy, // Learning items stay easy
                    category: .learning
                )
            }
    }

    private func gatherNewItems() -> [PlannedExercise] {
        var newItems: [PlannedExercise] = []

        for exerciseType in config.exerciseTypes {
            let curriculum = Curriculum.subTypes(for: exerciseType, grade: config.grade)
            let attemptedSubTypes = Set(
                user.stats
                    .filter { $0.exerciseType == exerciseType && $0.grade == config.grade }
                    .compactMap { $0.subType }
            )

            let unattempted = curriculum.filter { !attemptedSubTypes.contains($0) }

            for subType in unattempted {
                newItems.append(PlannedExercise(
                    exerciseType: exerciseType,
                    subType: subType,
                    difficulty: .easy,
                    category: .new
                ))
            }
        }

        // Prioritize new items by curriculum order (easier intervals first)
        return newItems.sorted { a, b in
            Curriculum.difficulty(of: a.subType) < Curriculum.difficulty(of: b.subType)
        }
    }

    private func gatherReinforcementItems() -> [PlannedExercise] {
        return user.stats
            .filter { stats in
                guard config.exerciseTypes.contains(stats.exerciseType) else { return false }
                guard stats.grade == config.grade else { return false }
                // High accuracy items for confidence building
                return stats.accuracy >= 0.8 && stats.totalAttempts >= 5
            }
            .shuffled()  // Random selection for variety
            .map { stats in
                PlannedExercise(
                    exerciseType: stats.exerciseType,
                    subType: stats.subType ?? "",
                    difficulty: calculateTargetDifficulty(for: stats),
                    category: .reinforcement
                )
            }
    }

    // MARK: - Composition Calculation

    private func calculateComposition(
        targetCount: Int,
        available: (reviews: Int, learning: Int, new: Int, reinforcement: Int)
    ) -> (reviews: Int, learning: Int, new: Int, reinforcement: Int) {

        // Start with ideal distribution
        var reviews = Int(Double(targetCount) * SessionComposition.targetReview)
        var learning = Int(Double(targetCount) * SessionComposition.targetLearning)
        var new = Int(Double(targetCount) * SessionComposition.targetNew)
        var reinforcement = Int(Double(targetCount) * SessionComposition.targetReinforcement)

        // Cap new items
        new = min(new, SessionComposition.maxNewPerSession, available.new)

        // Adjust to available
        reviews = min(reviews, available.reviews)
        learning = min(learning, available.learning)
        reinforcement = min(reinforcement, available.reinforcement)

        // Fill remaining slots prioritizing reviews > learning > reinforcement
        let allocated = reviews + learning + new + reinforcement
        var remaining = targetCount - allocated

        if remaining > 0 && available.reviews > reviews {
            let additional = min(remaining, available.reviews - reviews)
            reviews += additional
            remaining -= additional
        }

        if remaining > 0 && available.learning > learning {
            let additional = min(remaining, available.learning - learning)
            learning += additional
            remaining -= additional
        }

        if remaining > 0 && available.reinforcement > reinforcement {
            let additional = min(remaining, available.reinforcement - reinforcement)
            reinforcement += additional
            remaining -= additional
        }

        return (reviews, learning, new, reinforcement)
    }

    // MARK: - Interleaving

    private func interleaveExercises(
        new: [PlannedExercise],
        learning: [PlannedExercise],
        reviews: [PlannedExercise],
        reinforcement: [PlannedExercise]
    ) -> [PlannedExercise] {

        var result: [PlannedExercise] = []

        var newIterator = new.makeIterator()
        var learningIterator = learning.makeIterator()
        var reviewsIterator = reviews.makeIterator()
        var reinforcementIterator = reinforcement.makeIterator()

        // Pattern: R-R-L-R-Reinf-R-L-NEW-R-R-L...
        // Start with reviews to warm up, introduce new items after some successes
        let pattern: [ExerciseCategory] = [
            .review, .review, .learning, .review, .reinforcement,
            .review, .learning, .new, .review, .review, .learning
        ]
        var patternIndex = 0

        let totalTarget = new.count + learning.count + reviews.count + reinforcement.count

        while result.count < totalTarget {
            let category = pattern[patternIndex % pattern.count]
            patternIndex += 1

            var exercise: PlannedExercise? = nil

            // Try to get from desired category, fall back to others
            switch category {
            case .new:
                exercise = newIterator.next() ?? learningIterator.next() ?? reviewsIterator.next()
            case .learning:
                exercise = learningIterator.next() ?? reviewsIterator.next() ?? reinforcementIterator.next()
            case .review:
                exercise = reviewsIterator.next() ?? learningIterator.next() ?? reinforcementIterator.next()
            case .reinforcement:
                exercise = reinforcementIterator.next() ?? reviewsIterator.next() ?? learningIterator.next()
            case .challenge:
                continue  // Challenges added dynamically
            }

            if let ex = exercise {
                result.append(ex)
            }

            // Prevent infinite loop if all iterators exhausted
            if exercise == nil {
                break
            }
        }

        return result
    }

    // MARK: - Difficulty Calculation

    private func calculateTargetDifficulty(for stats: ExerciseStats) -> DifficultyLevel {
        if stats.accuracy >= 0.85 && stats.totalAttempts >= 20 {
            return .hard
        } else if stats.accuracy >= 0.7 && stats.totalAttempts >= 10 {
            return .medium
        }
        return .easy
    }
}
