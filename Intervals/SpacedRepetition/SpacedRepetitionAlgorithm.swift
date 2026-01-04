//
//  SpacedRepetitionAlgorithm.swift
//  Intervals
//

import Foundation

// MARK: - Algorithm Configuration

struct AlgorithmConfig {
    // SM-2 parameters
    var initialEaseFactor: Double = 2.5
    var minEaseFactor: Double = 1.3
    var maxEaseFactor: Double = 2.5

    // Learning phase
    var learningSteps: [Double] = [0.007, 0.042, 0.25, 1.0]  // In days (~10min, ~1hr, 6hr, 1day)
    var graduationThreshold: Int = 3
    var lapseGraduationThreshold: Int = 2

    // Mastery
    var masteryIntervalDays: Double = 21
    var masteryEaseFactor: Double = 2.0
    var maxIntervalDays: Double = 180

    // Session composition
    var targetNewPercent: Double = 0.15
    var targetLearningPercent: Double = 0.25
    var targetReviewPercent: Double = 0.40
    var targetReinforcementPercent: Double = 0.15
    var maxNewPerSession: Int = 5
    var maxConsecutiveSameType: Int = 3

    // Difficulty adjustment
    var accuracyThresholdForIncrease: Double = 0.9
    var accuracyThresholdForDecrease: Double = 0.5
    var responseTimeThresholdMs: Int = 3000

    // Break handling
    var breakThresholdDays: Int = 3
    var longBreakThresholdDays: Int = 14
    var maxDecayFactor: Double = 0.5

    static let `default` = AlgorithmConfig()
}

// MARK: - Spaced Repetition Algorithm

struct SpacedRepetitionAlgorithm {
    let config: AlgorithmConfig

    init(config: AlgorithmConfig = .default) {
        self.config = config
    }

    /// Update spaced repetition data after a response
    func updateSpacedRepetition(
        data: inout SpacedRepetitionData,
        quality: ResponseQuality
    ) {
        let q = Double(quality.rawValue)

        // Update ease factor (SM-2 formula, clamped)
        // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        let efDelta = 0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02)
        data.easeFactor = max(config.minEaseFactor, min(config.maxEaseFactor, data.easeFactor + efDelta))

        // Handle based on quality
        if quality.rawValue >= 3 {
            // Successful recall
            data.consecutiveCorrect += 1

            switch data.state {
            case .new, .learning:
                let threshold = graduationThreshold(for: data)
                if data.consecutiveCorrect >= threshold {
                    data.state = .reviewing
                    data.intervalDays = 1
                } else {
                    // Stay in learning, review again soon
                    data.state = .learning
                    data.intervalDays = learningInterval(step: data.consecutiveCorrect)
                }

            case .reviewing:
                // Increase interval
                data.intervalDays = fuzzedInterval(data.intervalDays * data.easeFactor)

                // Check for mastery
                if data.intervalDays >= config.masteryIntervalDays && data.easeFactor >= config.masteryEaseFactor {
                    data.state = .mastered
                }

            case .mastered:
                // Continue extending interval (slower growth)
                data.intervalDays = min(config.maxIntervalDays, fuzzedInterval(data.intervalDays * data.easeFactor * 0.9))

            case .lapsed:
                // Recovering from lapse
                if data.consecutiveCorrect >= config.lapseGraduationThreshold {
                    data.state = .reviewing
                    data.intervalDays = max(1, data.intervalDays * 0.5) // Reduced interval
                }
            }

        } else {
            // Failed recall
            data.consecutiveCorrect = 0

            if data.state == .mastered || data.state == .reviewing {
                data.state = .lapsed
                data.lapseCount += 1
                data.intervalDays = 0.5 // Review again soon

                // Penalize ease factor more for repeated lapses
                let lapsePenalty = min(0.3, Double(data.lapseCount) * 0.05)
                data.easeFactor = max(config.minEaseFactor, data.easeFactor - lapsePenalty)
            } else {
                data.state = .learning
                data.intervalDays = learningInterval(step: 0)
            }
        }

        // Calculate next review date
        data.nextReviewDate = Calendar.current.date(
            byAdding: .minute,
            value: Int(data.intervalDays * 24 * 60),
            to: Date()
        )
    }

    /// Learning phase intervals (in days, can be fractional for same-day review)
    func learningInterval(step: Int) -> Double {
        let steps = config.learningSteps
        if step < steps.count {
            return steps[step]
        }
        return steps.last ?? 1.0
    }

    /// How many correct answers needed to graduate from learning
    func graduationThreshold(for data: SpacedRepetitionData) -> Int {
        // More lenient for items that have lapsed before (user knows it somewhat)
        return data.lapseCount > 0 ? config.lapseGraduationThreshold : config.graduationThreshold
    }

    /// Add randomness to prevent review clusters
    func fuzzedInterval(_ interval: Double) -> Double {
        let fuzzFactor = Double.random(in: 0.95...1.05)
        return interval * fuzzFactor
    }

    // MARK: - Difficulty Calculation

    /// Calculate target difficulty based on recent performance
    func calculateTargetDifficulty(
        recentAttempts: [ExerciseAttempt],
        currentDifficulty: DifficultyLevel = .easy
    ) -> DifficultyLevel {
        guard !recentAttempts.isEmpty else {
            // New to this exercise type - start easy
            return .easy
        }

        // Calculate recent accuracy
        let recentCorrect = recentAttempts.filter { $0.isCorrect }.count
        let recentAccuracy = Double(recentCorrect) / Double(recentAttempts.count)

        // Calculate recent average response time for correct answers
        let correctAttempts = recentAttempts.filter { $0.isCorrect }
        let avgResponseTime = correctAttempts.isEmpty ? 5000 :
            correctAttempts.map { $0.responseTimeMs }.reduce(0, +) / correctAttempts.count

        // Decision matrix
        switch (recentAccuracy, avgResponseTime) {
        case (config.accuracyThresholdForIncrease..., ..<config.responseTimeThresholdMs):
            // High accuracy + fast = too easy, increase difficulty
            if let next = DifficultyLevel(rawValue: currentDifficulty.rawValue + 1) {
                return next
            }
            return currentDifficulty

        case (0.7..<config.accuracyThresholdForIncrease, _):
            // Good accuracy = stay at current level (optimal learning zone)
            return currentDifficulty

        case (config.accuracyThresholdForDecrease..<0.7, _):
            // Struggling a bit = maybe decrease or stay
            if avgResponseTime > 5000 {
                if let prev = DifficultyLevel(rawValue: currentDifficulty.rawValue - 1) {
                    return prev
                }
            }
            return currentDifficulty

        case (..<config.accuracyThresholdForDecrease, _):
            // Really struggling = decrease difficulty
            if let prev = DifficultyLevel(rawValue: currentDifficulty.rawValue - 1) {
                return prev
            }
            return currentDifficulty

        default:
            return currentDifficulty
        }
    }

    // MARK: - Break Handling

    /// Handle user returning after a break
    func handleUserReturn(
        stats: inout [ExerciseStats],
        daysSinceLastActivity: Int
    ) {
        guard daysSinceLastActivity > config.breakThresholdDays else { return }

        if daysSinceLastActivity > config.longBreakThresholdDays {
            // Long break: apply interval decay to prevent overwhelming backlog
            for i in stats.indices where stats[i].nextReviewDate != nil {
                // Reduce interval based on time away (forgetting curve)
                let decayFactor = min(config.maxDecayFactor, Double(daysSinceLastActivity) / 60.0)
                stats[i].intervalDays = Int(Double(stats[i].intervalDays) * (1.0 - decayFactor))

                // Spread reviews over next week instead of all at once
                let randomOffset = Int.random(in: 0...7)
                stats[i].nextReviewDate = Calendar.current.date(
                    byAdding: .day,
                    value: randomOffset,
                    to: Date()
                )
            }
        }
    }
}
