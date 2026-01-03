//
//  SessionResult.swift
//  Intervals
//

import Foundation

struct SessionResult {
    let totalQuestions: Int
    let correctAnswers: Int
    let xpEarned: Int
    let newStreak: Int
    let date: Date

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }

    var accuracyPercentage: Int {
        Int(accuracy * 100)
    }
}
