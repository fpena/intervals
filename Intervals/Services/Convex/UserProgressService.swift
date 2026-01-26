//
//  UserProgressService.swift
//  Intervals
//
//  Service for syncing user progress with Convex backend.
//  Supports multiple profiles per device for family subscriptions.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Convex Response Models

struct ConvexProfile: Codable, Identifiable {
    let _id: String
    let deviceId: String
    let name: String
    let avatarId: String
    let createdAt: Double
    let updatedAt: Double

    var id: String { _id }
}

struct ConvexUserStats: Codable {
    let _id: String
    let profileId: String
    let totalXp: Double
    let currentStreak: Double
    let longestStreak: Double
    let lastActivityAt: Double
    let exercisesCompleted: Double
    let createdAt: Double
    let updatedAt: Double
}

struct ConvexExerciseProgress: Codable, Identifiable {
    let _id: String
    let profileId: String
    let exerciseId: String
    let chapterId: String
    let bestScore: Double
    let bestStreak: Double
    let totalXpEarned: Double
    let completionCount: Double
    let attemptCount: Double
    let firstCompletedAt: Double
    let lastCompletedAt: Double
    let lastAttemptedAt: Double

    var id: String { _id }

    var starRating: Int {
        switch Int(bestScore) {
        case 90...100: return 3
        case 70..<90: return 2
        case 50..<70: return 1
        default: return 0
        }
    }
}

struct MutationResult: Codable {
    let success: Bool
}

struct RecordCompletionResult: Codable {
    let success: Bool
    let profile: ConvexProfile?
}

// MARK: - User Progress Service

@MainActor
class UserProgressService: ObservableObject {
    static let shared = UserProgressService()

    private let client: ConvexClient
    private let deviceId: String

    // MARK: - Published State

    @Published private(set) var profiles: [ConvexProfile] = []
    @Published private(set) var currentProfile: ConvexProfile?
    @Published private(set) var userStats: ConvexUserStats?
    @Published private(set) var exerciseProgress: [String: ConvexExerciseProgress] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    // MARK: - Local Storage Keys

    private let currentProfileIdKey = "com.intervals.currentProfileId"

    // MARK: - Computed Properties

    var totalXP: Int {
        Int(userStats?.totalXp ?? 0)
    }

    var currentStreak: Int {
        Int(userStats?.currentStreak ?? 0)
    }

    var longestStreak: Int {
        Int(userStats?.longestStreak ?? 0)
    }

    var exercisesCompleted: Int {
        Int(userStats?.exercisesCompleted ?? 0)
    }

    var hasProfile: Bool {
        currentProfile != nil
    }

    // MARK: - Init

    private init(client: ConvexClient = .shared) {
        self.client = client
        self.deviceId = Self.getOrCreateDeviceId()
    }

    // MARK: - Device ID Management

    private static func getOrCreateDeviceId() -> String {
        let key = "com.intervals.deviceId"

        if let existingId = UserDefaults.standard.string(forKey: key) {
            return existingId
        }

        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    // MARK: - Initialization

    /// Initialize service on app launch
    func initialize() async {
        isLoading = true
        error = nil

        do {
            // Fetch all profiles for this device
            let fetchedProfiles: [ConvexProfile] = try await client.query(
                "userProgress:getProfiles",
                args: ["deviceId": deviceId]
            )
            self.profiles = fetchedProfiles

            // Restore last selected profile or use first one
            if let savedProfileId = UserDefaults.standard.string(forKey: currentProfileIdKey),
               let profile = fetchedProfiles.first(where: { $0._id == savedProfileId }) {
                await selectProfile(profile)
            } else if let firstProfile = fetchedProfiles.first {
                await selectProfile(firstProfile)
            }
            // If no profiles exist, user needs to create one

        } catch {
            self.error = error
            print("UserProgressService: Failed to initialize - \(error)")
        }

        isLoading = false
    }

    // MARK: - Profile Management

    /// Create a new profile
    func createProfile(name: String, avatarId: String = "default") async -> ConvexProfile? {
        do {
            let profile: ConvexProfile = try await client.mutation(
                "userProgress:createProfile",
                args: [
                    "deviceId": deviceId,
                    "name": name,
                    "avatarId": avatarId
                ]
            )

            profiles.append(profile)
            await selectProfile(profile)
            return profile

        } catch {
            self.error = error
            print("UserProgressService: Failed to create profile - \(error)")
            return nil
        }
    }

    /// Select a profile to use
    func selectProfile(_ profile: ConvexProfile) async {
        currentProfile = profile
        UserDefaults.standard.set(profile._id, forKey: currentProfileIdKey)

        // Load data for this profile
        await loadProfileData(profileId: profile._id)
    }

    /// Update profile details
    func updateProfile(name: String? = nil, avatarId: String? = nil) async {
        guard let profileId = currentProfile?._id else { return }

        var args: [String: Any] = ["profileId": profileId]
        if let name = name { args["name"] = name }
        if let avatarId = avatarId { args["avatarId"] = avatarId }

        do {
            let updated: ConvexProfile = try await client.mutation(
                "userProgress:updateProfile",
                args: args
            )

            currentProfile = updated
            if let index = profiles.firstIndex(where: { $0._id == profileId }) {
                profiles[index] = updated
            }

        } catch {
            self.error = error
            print("UserProgressService: Failed to update profile - \(error)")
        }
    }

    /// Delete a profile
    func deleteProfile(_ profile: ConvexProfile) async -> Bool {
        do {
            let _: MutationResult = try await client.mutation(
                "userProgress:deleteProfile",
                args: ["profileId": profile._id]
            )

            profiles.removeAll { $0._id == profile._id }

            // If deleted current profile, switch to another
            if currentProfile?._id == profile._id {
                if let nextProfile = profiles.first {
                    await selectProfile(nextProfile)
                } else {
                    currentProfile = nil
                    userStats = nil
                    exerciseProgress = [:]
                    UserDefaults.standard.removeObject(forKey: currentProfileIdKey)
                }
            }

            return true

        } catch {
            self.error = error
            print("UserProgressService: Failed to delete profile - \(error)")
            return false
        }
    }

    // MARK: - Load Profile Data

    private func loadProfileData(profileId: String) async {
        do {
            // Load user stats
            let stats: ConvexUserStats? = try await client.query(
                "userProgress:getUserStats",
                args: ["profileId": profileId]
            )
            self.userStats = stats

            // Load all exercise progress
            let progress: [ConvexExerciseProgress] = try await client.query(
                "userProgress:getAllProgress",
                args: ["profileId": profileId]
            )

            self.exerciseProgress = Dictionary(
                uniqueKeysWithValues: progress.map { ($0.exerciseId, $0) }
            )

        } catch {
            self.error = error
            print("UserProgressService: Failed to load profile data - \(error)")
        }
    }

    // MARK: - Progress Queries

    /// Get progress for a specific exercise
    func getProgress(for exerciseId: String) -> ConvexExerciseProgress? {
        exerciseProgress[exerciseId]
    }

    /// Check if an exercise is completed
    func isExerciseCompleted(_ exerciseId: String) -> Bool {
        guard let progress = exerciseProgress[exerciseId] else { return false }
        return progress.completionCount > 0
    }

    /// Get star rating for an exercise
    func getStarRating(for exerciseId: String) -> Int {
        exerciseProgress[exerciseId]?.starRating ?? 0
    }

    /// Get all completed exercises for a chapter
    func getCompletedExercises(forChapter chapterId: String) -> [ConvexExerciseProgress] {
        exerciseProgress.values.filter { $0.chapterId == chapterId && $0.completionCount > 0 }
    }

    /// Get completion count for a chapter
    func getChapterCompletionCount(_ chapterId: String) -> Int {
        getCompletedExercises(forChapter: chapterId).count
    }

    /// Get total stars for a chapter
    func getChapterStars(_ chapterId: String) -> Int {
        getCompletedExercises(forChapter: chapterId).reduce(0) { $0 + $1.starRating }
    }

    // MARK: - Record Completion

    /// Record an exercise completion (auto-creates profile if needed)
    func recordCompletion(
        exerciseId: String,
        chapterId: String,
        score: Int,
        streak: Int,
        xpEarned: Int,
        passed: Bool,
        userName: String? = nil,
        userAvatarId: String? = nil
    ) async {
        do {
            var args: [String: Any] = [
                "deviceId": deviceId,
                "exerciseId": exerciseId,
                "chapterId": chapterId,
                "score": score,
                "streak": streak,
                "xpEarned": xpEarned,
                "passed": passed
            ]

            // Pass name/avatar for auto-profile creation
            if let name = userName ?? currentProfile?.name {
                args["name"] = name
            }
            if let avatarId = userAvatarId ?? currentProfile?.avatarId {
                args["avatarId"] = avatarId
            }

            let result: RecordCompletionResult = try await client.mutation(
                "userProgress:recordCompletion",
                args: args
            )

            // Update current profile if one was created/returned
            if let profile = result.profile {
                if currentProfile == nil {
                    currentProfile = profile
                    profiles.append(profile)
                    UserDefaults.standard.set(profile._id, forKey: currentProfileIdKey)
                }
            }

            // Refresh data after recording
            await refreshProgress(forExercise: exerciseId)
            await refreshUserStats()

        } catch {
            self.error = error
            print("UserProgressService: Failed to record completion - \(error)")
        }
    }

    // MARK: - Refresh Methods

    /// Refresh user stats
    func refreshUserStats() async {
        guard let profileId = currentProfile?._id else { return }

        do {
            let stats: ConvexUserStats? = try await client.query(
                "userProgress:getUserStats",
                args: ["profileId": profileId]
            )
            self.userStats = stats
        } catch {
            print("UserProgressService: Failed to refresh stats - \(error)")
        }
    }

    /// Refresh progress for a specific exercise
    func refreshProgress(forExercise exerciseId: String) async {
        guard let profileId = currentProfile?._id else { return }

        do {
            let progress: ConvexExerciseProgress? = try await client.query(
                "userProgress:getExerciseProgress",
                args: ["profileId": profileId, "exerciseId": exerciseId]
            )

            if let progress = progress {
                self.exerciseProgress[exerciseId] = progress
            }
        } catch {
            print("UserProgressService: Failed to refresh exercise progress - \(error)")
        }
    }

    /// Refresh all progress for a chapter
    func refreshChapterProgress(_ chapterId: String) async {
        guard let profileId = currentProfile?._id else { return }

        do {
            let progress: [ConvexExerciseProgress] = try await client.query(
                "userProgress:getChapterProgress",
                args: ["profileId": profileId, "chapterId": chapterId]
            )

            for p in progress {
                self.exerciseProgress[p.exerciseId] = p
            }
        } catch {
            print("UserProgressService: Failed to refresh chapter progress - \(error)")
        }
    }
}
