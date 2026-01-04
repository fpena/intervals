//
//  GradeSelectionView.swift
//  Intervals
//

import SwiftUI

struct GradeSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingScreenWrapper(viewModel: viewModel) {
            VStack(spacing: 16) {
                // Mascot
                OnboardingMascotView(pose: .thinking, size: 60)
                    .padding(.top, 12)

                // Headline
                Text(viewModel.headline(for: .gradeSelection))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Subtext
                Text(viewModel.subtext(for: .gradeSelection))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Grade list
                VStack(spacing: 8) {
                    ForEach(orderedGrades, id: \.self) { grade in
                        GradeOptionRow(
                            grade: grade,
                            isSelected: viewModel.selectedGrade == grade
                        ) {
                            viewModel.selectedGrade = grade
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .sheet(isPresented: $viewModel.showPlacementTest) {
            PlacementTestView(viewModel: viewModel)
        }
    }

    private var orderedGrades: [ABRSMGrade] {
        // Show in logical order: Just starting, Grade 1-8, Not sure
        var grades = ABRSMGrade.allCases.filter { $0 != .notSure }
        grades.sort { $0.rawValue < $1.rawValue }
        grades.append(.notSure)
        return grades
    }
}

struct GradeOptionRow: View {
    let grade: ABRSMGrade
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(grade.displayName)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appPrimary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Placement Test (Simplified)

struct PlacementTestView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion = 0
    @State private var correctAnswers = 0
    @State private var isComplete = false
    private let totalQuestions = 10

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isComplete {
                    placementResultView
                } else {
                    placementQuestionView
                }
            }
            .navigationTitle("Placement Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelPlacementTest()
                        dismiss()
                    }
                }
            }
        }
    }

    private var placementQuestionView: some View {
        VStack(spacing: 32) {
            // Progress
            ProgressView(value: Double(currentQuestion), total: Double(totalQuestions))
                .tint(Color.appPrimary)
                .padding(.horizontal)

            Text("Question \(currentQuestion + 1) of ~\(totalQuestions)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            // Mascot
            OnboardingMascotView(pose: .encouraging, size: 100)

            Text("Listen and identify...")
                .font(.title2)
                .fontWeight(.semibold)

            Text("(Placement test questions would appear here)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            // Simulated answer buttons
            HStack(spacing: 16) {
                Button("Skip") {
                    advanceQuestion(correct: false)
                }
                .buttonStyle(.bordered)

                Button("Answer") {
                    advanceQuestion(correct: Bool.random())
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom, 32)
        }
    }

    private var placementResultView: some View {
        VStack(spacing: 24) {
            Spacer()

            OnboardingMascotView(pose: .celebrating, size: 120)

            Text("Great job!")
                .font(.largeTitle)
                .fontWeight(.bold)

            let recommendedGrade = calculateRecommendedGrade()

            Text("We think \(recommendedGrade.displayName) is a great starting point!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("You can always adjust this in settings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Continue") {
                let score = Double(correctAnswers) / Double(totalQuestions)
                viewModel.completePlacementTest(recommendedGrade: recommendedGrade, score: score)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom, 32)
        }
    }

    private func advanceQuestion(correct: Bool) {
        if correct {
            correctAnswers += 1
        }
        currentQuestion += 1

        if currentQuestion >= totalQuestions {
            isComplete = true
        }
    }

    private func calculateRecommendedGrade() -> ABRSMGrade {
        let ratio = Double(correctAnswers) / Double(totalQuestions)
        switch ratio {
        case 0..<0.2: return .preGrade1
        case 0.2..<0.35: return .grade1
        case 0.35..<0.5: return .grade2
        case 0.5..<0.6: return .grade3
        case 0.6..<0.7: return .grade4
        case 0.7..<0.8: return .grade5
        case 0.8..<0.9: return .grade6
        case 0.9..<0.95: return .grade7
        default: return .grade8
        }
    }
}

#Preview {
    GradeSelectionView(viewModel: OnboardingViewModel())
}
