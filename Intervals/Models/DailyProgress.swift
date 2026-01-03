//
//  DailyProgress.swift
//  Intervals
//

import Foundation
import SwiftData

@Model
final class DailyProgress {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID

    // MARK: - Date (stored as start of day)
    var date: Date

    // MARK: - Activity Metrics
    var exercisesCompleted: Int
    var correctAnswers: Int
    var timeSpentSeconds: Int
    var xpEarned: Int

    // MARK: - Goal Tracking
    var dailyGoalMet: Bool

    // MARK: - Relationship
    var user: UserProfile?

    // MARK: - Initialization
    init(date: Date = Date()) {
        self.id = UUID()
        // Normalize to start of day
        self.date = Calendar.current.startOfDay(for: date)
        self.exercisesCompleted = 0
        self.correctAnswers = 0
        self.timeSpentSeconds = 0
        self.xpEarned = 0
        self.dailyGoalMet = false
    }

    // MARK: - Computed Properties
    var accuracy: Double {
        guard exercisesCompleted > 0 else { return 0 }
        return Double(correctAnswers) / Double(exercisesCompleted)
    }

    var timeSpentMinutes: Int {
        timeSpentSeconds / 60
    }
}
