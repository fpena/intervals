//
//  ExerciseHeaderView.swift
//  Intervals
//

import SwiftUI

struct ExerciseHeaderView: View {
    let progress: Double
    let currentQuestion: Int
    let totalQuestions: Int
    let sessionXP: Int
    let onBack: () -> Void

    @State private var animatedXP: Int = 0

    var body: some View {
        HStack(spacing: 24) {
            backButton

            Spacer()

            progressSection

            Spacer()

            xpIndicator
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .onChange(of: sessionXP) { oldValue, newValue in
            withAnimation(.spring) {
                animatedXP = newValue
            }
        }
        .onAppear {
            animatedXP = sessionXP
        }
    }

    private var backButton: some View {
        Button(action: onBack) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                Text("Exit")
                    .font(.body.weight(.medium))
            }
            .foregroundColor(.appPrimary)
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .accessibilityLabel("Exit exercise")
        .accessibilityHint("Double tap to exit the exercise")
    }

    private var progressSection: some View {
        HStack(spacing: 16) {
            ProgressView(value: progress)
                .tint(.appPrimary)
                .frame(width: 200)
                .accessibilityHidden(true)

            Text("Question \(currentQuestion) of \(totalQuestions)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .accessibilityLabel("Question \(currentQuestion) of \(totalQuestions)")
        }
    }

    private var xpIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .foregroundColor(.appAccent)

            Text("+\(animatedXP)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.appAccent)
                .contentTransition(.numericText())

            Text("XP")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.appAccent.opacity(0.8))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(animatedXP) experience points earned")
    }
}

#Preview {
    VStack {
        ExerciseHeaderView(
            progress: 0.4,
            currentQuestion: 4,
            totalQuestions: 10,
            sessionXP: 45,
            onBack: {}
        )

        Spacer()
    }
}
