//
//  Chapter.swift
//  Intervals
//

import Foundation

struct Chapter: Identifiable, Codable, Hashable {
    let _id: String
    let name: String
    let description: String
    let isActive: Bool
    let isBossChapter: Bool
    let sortOrder: Double
    let trackId: String
    let unlockXpThreshold: Double

    var id: String { _id }

    /// Whether this chapter is unlocked based on user's XP
    func isUnlocked(userXp: Double) -> Bool {
        userXp >= unlockXpThreshold
    }
}
