//
//  ProgressService.swift
//  Intervals
//

import SwiftData
import Foundation

@MainActor
class ProgressService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Records an exercise attempt and updates all related stats
    func recordAttempt(
        user: UserProfile,
        exerciseType: ExerciseType,
        grade: Grade,
        questionData: String,
        correctAnswer: String,
        userAnswer: String,
        isCorrect: Bool,
        responseTimeMs: Int,
        sessionId: UUID? = nil
    ) {
        // Calculate XP
        let baseXP = isCorrect ? 10 : 2
        let speedBonus = isCorrect && responseTimeMs < 3000 ? 5 : 0
        let xpEarned = baseXP + speedBonus

        // 1. Create attempt record
        let attempt = ExerciseAttempt(
            exerciseType: exerciseType,
            grade: grade,
            questionData: questionData,
            correctAnswer: correctAnswer,
            userAnswer: userAnswer,
            isCorrect: isCorrect,
            responseTimeMs: responseTimeMs,
            xpEarned: xpEarned,
            sessionId: sessionId
        )
        attempt.user = user
        modelContext.insert(attempt)

        // 2. Update exercise stats
        updateExerciseStats(
            user: user,
            exerciseType: exerciseType,
            grade: grade,
            isCorrect: isCorrect,
            responseTimeMs: responseTimeMs
        )

        // 3. Update daily progress
        updateDailyProgress(
            user: user,
            isCorrect: isCorrect,
            xpEarned: xpEarned
        )

        // 4. Update user XP and streak
        user.totalXP += xpEarned
        updateStreak(user: user)
        user.updatedAt = Date()

        // 5. Check for achievements
        checkAchievements(user: user)

        try? modelContext.save()
    }

    private func updateExerciseStats(
        user: UserProfile,
        exerciseType: ExerciseType,
        grade: Grade,
        isCorrect: Bool,
        responseTimeMs: Int
    ) {
        // Find or create stats for this exercise type/grade
        let stats = user.stats.first {
            $0.exerciseType == exerciseType && $0.grade == grade && $0.subType == nil
        } ?? {
            let newStats = ExerciseStats(exerciseType: exerciseType, grade: grade)
            newStats.user = user
            modelContext.insert(newStats)
            return newStats
        }()

        stats.totalAttempts += 1
        if isCorrect { stats.correctAttempts += 1 }
        stats.totalResponseTimeMs += responseTimeMs
        stats.lastAttemptDate = Date()

        // Update spaced repetition (simplified SM-2)
        updateSpacedRepetition(stats: stats, isCorrect: isCorrect)
    }

    private func updateSpacedRepetition(stats: ExerciseStats, isCorrect: Bool) {
        if isCorrect {
            stats.intervalDays = Int(Double(stats.intervalDays) * stats.easeFactor)
            stats.easeFactor = min(2.5, stats.easeFactor + 0.1)
        } else {
            stats.intervalDays = 1
            stats.easeFactor = max(1.3, stats.easeFactor - 0.2)
        }
        stats.nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: stats.intervalDays,
            to: Date()
        )
    }

    private func updateDailyProgress(user: UserProfile, isCorrect: Bool, xpEarned: Int) {
        let today = Calendar.current.startOfDay(for: Date())

        let progress = user.dailyProgress.first {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        } ?? {
            let newProgress = DailyProgress(date: today)
            newProgress.user = user
            modelContext.insert(newProgress)
            return newProgress
        }()

        progress.exercisesCompleted += 1
        if isCorrect { progress.correctAnswers += 1 }
        progress.xpEarned += xpEarned

        // Check if daily goal met
        if progress.timeSpentMinutes >= user.dailyGoalMinutes {
            progress.dailyGoalMet = true
        }
    }

    private func updateStreak(user: UserProfile) {
        let today = Calendar.current.startOfDay(for: Date())

        guard let lastActivity = user.lastActivityDate else {
            // First activity ever
            user.currentStreak = 1
            user.longestStreak = 1
            user.lastActivityDate = today
            return
        }

        let lastActivityDay = Calendar.current.startOfDay(for: lastActivity)

        if Calendar.current.isDate(lastActivityDay, inSameDayAs: today) {
            // Already practiced today, no change
            return
        }

        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
           Calendar.current.isDate(lastActivityDay, inSameDayAs: yesterday) {
            // Practiced yesterday, increment streak
            user.currentStreak += 1
            user.longestStreak = max(user.longestStreak, user.currentStreak)
        } else {
            // Streak broken
            user.currentStreak = 1
        }

        user.lastActivityDate = today
    }

    private func checkAchievements(user: UserProfile) {
        let unlockedIds = Set(user.achievements.map { $0.achievementId })

        // Check streak achievements
        if user.currentStreak >= 1 && !unlockedIds.contains(Achievement.firstDay.rawValue) {
            unlockAchievement(.firstDay, for: user)
        }
        if user.currentStreak >= 7 && !unlockedIds.contains(Achievement.weekStreak.rawValue) {
            unlockAchievement(.weekStreak, for: user)
        }
        if user.currentStreak >= 30 && !unlockedIds.contains(Achievement.monthStreak.rawValue) {
            unlockAchievement(.monthStreak, for: user)
        }
        if user.currentStreak >= 100 && !unlockedIds.contains(Achievement.hundredDayStreak.rawValue) {
            unlockAchievement(.hundredDayStreak, for: user)
        }

        // Check exercise count achievements
        let totalExercises = user.attempts.count
        if totalExercises >= 10 && !unlockedIds.contains(Achievement.first10Exercises.rawValue) {
            unlockAchievement(.first10Exercises, for: user)
        }
        if totalExercises >= 100 && !unlockedIds.contains(Achievement.first100Exercises.rawValue) {
            unlockAchievement(.first100Exercises, for: user)
        }
        if totalExercises >= 1000 && !unlockedIds.contains(Achievement.first1000Exercises.rawValue) {
            unlockAchievement(.first1000Exercises, for: user)
        }
    }

    private func unlockAchievement(_ achievement: Achievement, for user: UserProfile) {
        let unlocked = UnlockedAchievement(achievement: achievement)
        unlocked.user = user
        modelContext.insert(unlocked)

        // Award XP for achievement
        user.totalXP += achievement.xpReward
    }

    /// Returns exercise types/subtypes that are due for review, prioritized by urgency
    func getExercisesDueForReview(user: UserProfile, limit: Int = 10) -> [ExerciseStats] {
        let now = Date()

        return user.stats
            .filter { stats in
                guard let nextReview = stats.nextReviewDate else { return true }
                return nextReview <= now
            }
            .sorted { a, b in
                // Prioritize: overdue > low accuracy > fewer attempts
                let aOverdue = a.nextReviewDate.map { now.timeIntervalSince($0) } ?? .infinity
                let bOverdue = b.nextReviewDate.map { now.timeIntervalSince($0) } ?? .infinity

                if abs(aOverdue - bOverdue) > 86400 { // More than 1 day difference
                    return aOverdue > bOverdue
                }

                if abs(a.accuracy - b.accuracy) > 0.1 {
                    return a.accuracy < b.accuracy
                }

                return a.totalAttempts < b.totalAttempts
            }
            .prefix(limit)
            .map { $0 }
    }

    /// Returns exercises the user hasn't tried yet for their current grade
    func getNewExercises(user: UserProfile, exerciseType: ExerciseType) -> [String] {
        // This would return subTypes (e.g., interval names) not yet attempted
        // Implementation depends on your curriculum data structure
        let attemptedSubTypes = Set(
            user.stats
                .filter { $0.exerciseType == exerciseType && $0.grade == user.currentGrade }
                .compactMap { $0.subType }
        )

        // Return all available subtypes minus attempted ones
        // You'd need a curriculum definition to complete this
        return []  // Placeholder
    }
}
