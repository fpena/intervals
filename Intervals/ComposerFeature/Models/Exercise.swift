//
//  Exercise.swift
//  Intervals
//

import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let _id: String
    let chapterId: String
    let config: String
    let difficulty: Double
    let exerciseTypeSlug: String
    let instructions: String
    let isActive: Bool
    let name: String
    let passingScorePercent: Double
    let sortOrder: Double
    let xpReward: Double

    var id: String { _id }

    /// Difficulty as a human-readable label
    var difficultyLabel: String {
        switch difficulty {
        case 0..<2: return "Easy"
        case 2..<4: return "Medium"
        case 4..<6: return "Hard"
        default: return "Expert"
        }
    }
}
