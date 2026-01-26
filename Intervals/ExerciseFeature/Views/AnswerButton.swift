//
//  AnswerButton.swift
//  Intervals
//

import SwiftUI

struct AnswerButton: View {
    let title: String
    let isSelected: Bool
    let isCorrectAnswer: Bool
    let hasAnswered: Bool
    let isDisabled: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var backgroundColor: Color {
        guard hasAnswered else {
            return Color(.secondarySystemBackground)
        }

        if isSelected {
            return isCorrectAnswer ? .appSuccess : .appError
        } else if isCorrectAnswer {
            return .appSuccess.opacity(0.3)
        }

        return Color(.secondarySystemBackground)
    }

    private var foregroundColor: Color {
        guard hasAnswered else {
            return .primary
        }

        if isSelected || isCorrectAnswer {
            return .white
        }

        return .primary.opacity(0.5)
    }

    private var borderColor: Color {
        guard !hasAnswered else { return .clear }
        return .appPrimary.opacity(0.3)
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 56)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(borderColor, lineWidth: 2)
                )
                .scaleEffect(scaleEffect)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.6),
                    value: isSelected
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var scaleEffect: CGFloat {
        guard !reduceMotion else { return 1.0 }
        return isSelected && hasAnswered && isCorrectAnswer ? 1.05 : 1.0
    }

    private var accessibilityHint: String {
        if hasAnswered {
            if isSelected {
                return isCorrectAnswer ? "Correct answer" : "Incorrect answer"
            } else if isCorrectAnswer {
                return "This was the correct answer"
            }
            return "Answer option"
        }
        return "Double tap to select this answer"
    }
}

#Preview {
    VStack(spacing: 16) {
        AnswerButton(
            title: "Minor 3rd",
            isSelected: false,
            isCorrectAnswer: false,
            hasAnswered: false,
            isDisabled: false,
            action: {}
        )

        AnswerButton(
            title: "Major 3rd",
            isSelected: true,
            isCorrectAnswer: true,
            hasAnswered: true,
            isDisabled: true,
            action: {}
        )

        AnswerButton(
            title: "Perfect 4th",
            isSelected: true,
            isCorrectAnswer: false,
            hasAnswered: true,
            isDisabled: true,
            action: {}
        )

        AnswerButton(
            title: "Perfect 5th",
            isSelected: false,
            isCorrectAnswer: true,
            hasAnswered: true,
            isDisabled: true,
            action: {}
        )
    }
    .padding()
}
