//
//  UnlockedAchievement.swift
//  Intervals
//

import Foundation
import SwiftData

@Model
final class UnlockedAchievement {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID

    // MARK: - Achievement Reference
    var achievementId: String  // References Achievement.rawValue

    // MARK: - Unlock Details
    var unlockedAt: Date
    var viewed: Bool  // Has user seen the unlock notification?

    // MARK: - Relationship
    var user: UserProfile?

    // MARK: - Initialization
    init(achievement: Achievement) {
        self.id = UUID()
        self.achievementId = achievement.rawValue
        self.unlockedAt = Date()
        self.viewed = false
    }

    // MARK: - Computed Properties
    var achievement: Achievement? {
        Achievement(rawValue: achievementId)
    }
}
