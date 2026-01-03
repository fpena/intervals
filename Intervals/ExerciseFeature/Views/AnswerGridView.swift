//
//  AnswerGridView.swift
//  Intervals
//

import SwiftUI

struct AnswerGridView: View {
    let answers: [String]
    let correctAnswer: String
    let selectedAnswer: String?
    let hasAnswered: Bool
    let isDisabled: Bool
    let onSelect: (String) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(answers, id: \.self) { answer in
                AnswerButton(
                    title: answer,
                    isSelected: selectedAnswer == answer,
                    isCorrectAnswer: answer == correctAnswer,
                    hasAnswered: hasAnswered,
                    isDisabled: isDisabled
                ) {
                    onSelect(answer)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 32) {
        AnswerGridView(
            answers: ["Minor 2nd", "Major 2nd", "Minor 3rd", "Major 3rd"],
            correctAnswer: "Minor 3rd",
            selectedAnswer: nil,
            hasAnswered: false,
            isDisabled: false,
            onSelect: { _ in }
        )

        AnswerGridView(
            answers: ["Minor 2nd", "Major 2nd", "Minor 3rd", "Major 3rd"],
            correctAnswer: "Minor 3rd",
            selectedAnswer: "Minor 3rd",
            hasAnswered: true,
            isDisabled: true,
            onSelect: { _ in }
        )

        AnswerGridView(
            answers: ["Minor 2nd", "Major 2nd", "Minor 3rd", "Major 3rd"],
            correctAnswer: "Minor 3rd",
            selectedAnswer: "Major 2nd",
            hasAnswered: true,
            isDisabled: true,
            onSelect: { _ in }
        )
    }
    .padding()
}
