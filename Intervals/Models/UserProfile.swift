//
//  UserProfile.swift
//  Intervals
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var name: String
    var avatarId: String  // References avatar asset name
    var dateOfBirth: Date?  // Optional, for age-appropriate content

    // MARK: - Progress
    var currentGrade: Grade
    var totalXP: Int  // Gamification points

    // MARK: - Streak
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?

    // MARK: - Preferences (embedded)
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var preferredInstrument: InstrumentType
    var notificationsEnabled: Bool
    var dailyGoalMinutes: Int  // Target practice time per day

    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \ExerciseAttempt.user)
    var attempts: [ExerciseAttempt] = []

    @Relationship(deleteRule: .cascade, inverse: \ExerciseStats.user)
    var stats: [ExerciseStats] = []

    @Relationship(deleteRule: .cascade, inverse: \DailyProgress.user)
    var dailyProgress: [DailyProgress] = []

    @Relationship(deleteRule: .cascade, inverse: \UnlockedAchievement.user)
    var achievements: [UnlockedAchievement] = []

    // MARK: - Initialization
    init(
        name: String,
        avatarId: String = "default_avatar",
        dateOfBirth: Date? = nil,
        currentGrade: Grade = .initial
    ) {
        self.id = UUID()
        self.name = name
        self.avatarId = avatarId
        self.dateOfBirth = dateOfBirth
        self.currentGrade = currentGrade
        self.totalXP = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastActivityDate = nil
        self.soundEnabled = true
        self.hapticsEnabled = true
        self.preferredInstrument = .piano
        self.notificationsEnabled = true
        self.dailyGoalMinutes = 10
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    var age: Int? {
        guard let dob = dateOfBirth else { return nil }
        return Calendar.current.dateComponents([.year], from: dob, to: Date()).year
    }

    var isChild: Bool {
        guard let age = age else { return true }  // Default to child-safe
        return age < 13
    }
}
