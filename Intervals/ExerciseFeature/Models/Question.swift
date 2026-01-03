//
//  Question.swift
//  Intervals
//

import Foundation

struct Question: Identifiable {
    let id: UUID
    let type: ExerciseType
    let correctAnswer: String
    let allAnswers: [String]
    let intervalType: IntervalType?

    init(
        id: UUID = UUID(),
        type: ExerciseType,
        correctAnswer: String,
        allAnswers: [String],
        intervalType: IntervalType? = nil
    ) {
        self.id = id
        self.type = type
        self.correctAnswer = correctAnswer
        self.allAnswers = allAnswers
        self.intervalType = intervalType
    }

    /// Convenience initializer for interval questions
    init(
        id: UUID = UUID(),
        intervalType: IntervalType,
        distractors: [IntervalType]
    ) {
        self.id = id
        self.type = .intervals
        self.correctAnswer = intervalType.rawValue
        self.intervalType = intervalType

        var answers = distractors.map { $0.rawValue }
        answers.append(intervalType.rawValue)
        self.allAnswers = answers.shuffled()
    }
}

// MARK: - Sample Data

extension Question {
    static let sampleIntervalQuestions: [Question] = [
        Question(
            intervalType: .minorThird,
            distractors: [.minorSecond, .majorSecond, .majorThird]
        ),
        Question(
            intervalType: .perfectFifth,
            distractors: [.perfectFourth, .tritone, .minorSixth]
        ),
        Question(
            intervalType: .majorSecond,
            distractors: [.minorSecond, .minorThird, .majorThird]
        ),
        Question(
            intervalType: .perfectFourth,
            distractors: [.majorThird, .tritone, .perfectFifth]
        ),
        Question(
            intervalType: .minorSixth,
            distractors: [.perfectFifth, .majorSixth, .minorSeventh]
        ),
        Question(
            intervalType: .majorSeventh,
            distractors: [.minorSeventh, .octave, .majorSixth]
        ),
        Question(
            intervalType: .tritone,
            distractors: [.perfectFourth, .perfectFifth, .minorSixth]
        ),
        Question(
            intervalType: .octave,
            distractors: [.majorSeventh, .minorSeventh, .majorSixth]
        ),
        Question(
            intervalType: .minorSecond,
            distractors: [.majorSecond, .minorThird, .majorThird]
        ),
        Question(
            intervalType: .majorSixth,
            distractors: [.perfectFifth, .minorSixth, .minorSeventh]
        )
    ]

    /// Generate random interval questions
    static func generateIntervalQuestions(count: Int, intervals: [IntervalType] = IntervalType.allCases) -> [Question] {
        var questions: [Question] = []

        for _ in 0..<count {
            let targetInterval = intervals.randomElement()!
            let distractors = intervals
                .filter { $0 != targetInterval }
                .shuffled()
                .prefix(3)

            questions.append(Question(
                intervalType: targetInterval,
                distractors: Array(distractors)
            ))
        }

        return questions
    }
}
