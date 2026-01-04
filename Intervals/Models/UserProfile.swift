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

    // MARK: - Onboarding
    var ageGroupRaw: String?  // AgeGroup raw value
    var instrumentsRaw: [String]  // OnboardingInstrument raw values
    var primaryInstrumentRaw: String?  // OnboardingInstrument raw value
    var goalRaw: String?  // LearningGoal raw value
    var setupCompletedAt: Date?
    var setupFlowRaw: String?  // SetupFlow raw value
    var placementTestTaken: Bool
    var placementTestScore: Double?

    // MARK: - Reminder Settings
    var reminderEnabled: Bool
    var reminderTime: Date?
    var reminderDaysRaw: [Int]  // Weekday raw values

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
        name: String = OnboardingDefaults.name,
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

        // Onboarding defaults
        self.ageGroupRaw = nil
        self.instrumentsRaw = []
        self.primaryInstrumentRaw = nil
        self.goalRaw = nil
        self.setupCompletedAt = nil
        self.setupFlowRaw = nil
        self.placementTestTaken = false
        self.placementTestScore = nil
        self.reminderEnabled = false
        self.reminderTime = nil
        self.reminderDaysRaw = []
    }

    /// Create with onboarding defaults applied
    static func withDefaults() -> UserProfile {
        let profile = UserProfile()
        profile.name = OnboardingDefaults.name
        profile.ageGroup = OnboardingDefaults.ageGroup
        profile.instruments = [OnboardingDefaults.instrument]
        profile.primaryInstrument = OnboardingDefaults.instrument
        profile.goal = OnboardingDefaults.goal
        profile.currentGrade = OnboardingDefaults.grade.toGrade
        profile.reminderEnabled = OnboardingDefaults.reminderEnabled
        return profile
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

    // MARK: - Onboarding Computed Properties

    var ageGroup: AgeGroup? {
        get {
            guard let raw = ageGroupRaw else { return nil }
            return AgeGroup(rawValue: raw)
        }
        set { ageGroupRaw = newValue?.rawValue }
    }

    var instruments: [OnboardingInstrument] {
        get { instrumentsRaw.compactMap { OnboardingInstrument(rawValue: $0) } }
        set { instrumentsRaw = newValue.map { $0.rawValue } }
    }

    var primaryInstrument: OnboardingInstrument? {
        get {
            guard let raw = primaryInstrumentRaw else { return nil }
            return OnboardingInstrument(rawValue: raw)
        }
        set { primaryInstrumentRaw = newValue?.rawValue }
    }

    var goal: LearningGoal? {
        get {
            guard let raw = goalRaw else { return nil }
            return LearningGoal(rawValue: raw)
        }
        set { goalRaw = newValue?.rawValue }
    }

    var setupFlow: SetupFlow? {
        get {
            guard let raw = setupFlowRaw else { return nil }
            return SetupFlow(rawValue: raw)
        }
        set { setupFlowRaw = newValue?.rawValue }
    }

    var reminderDays: [Weekday] {
        get { reminderDaysRaw.compactMap { Weekday(rawValue: $0) } }
        set { reminderDaysRaw = newValue.map { $0.rawValue } }
    }

    var isSetupComplete: Bool {
        setupCompletedAt != nil
    }

    var displayName: String {
        name.isEmpty ? OnboardingDefaults.name : name
    }

    // MARK: - Onboarding Methods

    func completeOnboarding() {
        setupCompletedAt = Date()
        updatedAt = Date()
    }

    func skipOnboarding() {
        // Apply defaults when skipping
        name = OnboardingDefaults.name
        ageGroup = OnboardingDefaults.ageGroup
        instruments = [OnboardingDefaults.instrument]
        primaryInstrument = OnboardingDefaults.instrument
        goal = OnboardingDefaults.goal
        currentGrade = OnboardingDefaults.grade.toGrade
        reminderEnabled = OnboardingDefaults.reminderEnabled
        setupCompletedAt = Date()
        updatedAt = Date()
    }
}
