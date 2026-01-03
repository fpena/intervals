//
//  ExerciseView.swift
//  Intervals
//

import SwiftUI

struct ExerciseView: View {
    @State private var viewModel = ExerciseViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if viewModel.isSessionComplete {
                    sessionCompleteView
                } else {
                    questionContent
                }
            }
            .safeAreaPadding(.horizontal)

            FeedbackOverlayView(
                isCorrect: viewModel.isCorrect,
                isVisible: viewModel.showFeedback
            )
        }
        .persistentSystemOverlays(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 16) {
                    ProgressView(value: viewModel.progress)
                        .tint(.appPrimary)
                        .frame(width: 200)

                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.totalQuestions)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.appAccent)

                    Text("+\(viewModel.sessionXP)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.appAccent)
                        .contentTransition(.numericText())

                    Text("XP")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.appAccent.opacity(0.8))
                }
            }
        }
    }

    private var questionContent: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left - Mascot (25% of screen)
                VStack {
                    Spacer()
                    MascotView(
                        mood: viewModel.mascotMood,
                        promptText: viewModel.promptText
                    )
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.25)

                // Middle - Play Button (25% of screen)
                VStack {
                    Spacer()
                    PlayButtonView(
                        isPlaying: viewModel.isPlaying,
                        hasPlayedAudio: viewModel.hasPlayedAudio,
                        isDisabled: viewModel.hasAnswered,
                        onPlay: { viewModel.playAudio() }
                    )
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.25)

                // Right - Interval Selection (50% of screen)
                VStack(spacing: 24) {
                    Spacer()

                    if let question = viewModel.currentQuestion {
                        AnswerGridView(
                            answers: question.allAnswers,
                            correctAnswer: question.correctAnswer,
                            selectedAnswer: viewModel.selectedAnswer,
                            hasAnswered: viewModel.hasAnswered,
                            isDisabled: !viewModel.canSelectAnswer,
                            onSelect: { answer in
                                viewModel.selectAnswer(answer)
                            }
                        )
                        .frame(maxWidth: 400)
                    }

                    ScoreDisplayView(
                        streak: viewModel.currentStreak,
                        xp: viewModel.sessionXP
                    )

                    Spacer()
                }
                .frame(width: geometry.size.width * 0.50)
            }
        }
        .padding(.horizontal, 16)
    }

    private var sessionCompleteView: some View {
        HStack(spacing: 48) {
            // Left side - Trophy and Title
            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "trophy.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.appAccent)

                Text("Session Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()
            }
            .frame(maxWidth: .infinity)

            // Right side - Stats and Buttons
            VStack(spacing: 24) {
                Spacer()

                if let result = viewModel.sessionResult {
                    VStack(spacing: 12) {
                        StatRow(
                            label: "Correct Answers",
                            value: "\(result.correctAnswers)/\(result.totalQuestions)"
                        )
                        StatRow(
                            label: "Accuracy",
                            value: "\(result.accuracyPercentage)%"
                        )
                        StatRow(
                            label: "XP Earned",
                            value: "+\(result.xpEarned)"
                        )
                        StatRow(
                            label: "Best Streak",
                            value: "\(result.newStreak)"
                        )
                    }
                    .padding()
                    .frame(width: 280)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                }

                VStack(spacing: 12) {
                    Button {
                        viewModel.restartSession()
                    } label: {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 280, height: 56)
                            .background(Color.appPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.appPrimary)
                            .frame(width: 280, height: 56)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 48)
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack {
        ExerciseView()
    }
}
