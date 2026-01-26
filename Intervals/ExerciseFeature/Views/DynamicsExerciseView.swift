//
//  DynamicsExerciseView.swift
//  Intervals
//

import SwiftUI

struct DynamicsExerciseView: View {
    let exercise: Exercise
    let themeColor: Color
    var onComplete: ((ExerciseResult) -> Void)?

    @State private var viewModel: DynamicsViewModel?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let viewModel = viewModel {
                DynamicsGameContent(
                    viewModel: viewModel,
                    dismiss: dismiss,
                    onComplete: { result in
                        onComplete?(result)
                    }
                )
            } else {
                ProgressView()
                    .onAppear {
                        viewModel = DynamicsViewModel(
                            exercise: exercise,
                            themeColor: themeColor
                        )
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Game Content

private struct DynamicsGameContent: View {
    @Bindable var viewModel: DynamicsViewModel
    let dismiss: DismissAction
    var onComplete: ((ExerciseResult) -> Void)?

    var body: some View {
        ZStack {
            gardenBackground

            VStack(spacing: 0) {
                if viewModel.isSessionComplete {
                    DynamicsSessionCompleteView(
                        viewModel: viewModel,
                        dismiss: dismiss,
                        onComplete: onComplete
                    )
                } else {
                    gameplayView
                }
            }
            .safeAreaPadding(.horizontal)

            // Feedback overlay
            DynamicsFeedbackOverlay(
                isCorrect: viewModel.isCorrect,
                dynamicLevel: viewModel.currentQuestion?.correctAnswer,
                isVisible: viewModel.showFeedback
            )
        }
        .persistentSystemOverlays(.hidden)
        .toolbar {
            ToolbarItem(placement: .principal) {
                progressToolbar
            }

            ToolbarItem(placement: .topBarTrailing) {
                xpDisplay
            }
        }
    }

    private var gardenBackground: some View {
        LinearGradient(
            colors: [
                viewModel.themeColor.opacity(0.15),
                viewModel.themeColor.opacity(0.05),
                Color(.systemGroupedBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var progressToolbar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(0..<viewModel.totalQuestions, id: \.self) { index in
                    Circle()
                        .fill(progressDotColor(for: index))
                        .frame(width: 10, height: 10)
                }
            }

            Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.totalQuestions)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }

    private func progressDotColor(for index: Int) -> Color {
        if index < viewModel.currentQuestionIndex {
            return viewModel.themeColor
        } else if index == viewModel.currentQuestionIndex {
            return viewModel.themeColor.opacity(0.5)
        } else {
            return Color(.systemGray4)
        }
    }

    private var xpDisplay: some View {
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

    // MARK: - Gameplay View

    private var gameplayView: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            if isLandscape {
                landscapeLayout(geometry: geometry)
            } else {
                portraitLayout(geometry: geometry)
            }
        }
        .padding()
    }

    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 24) {
            VStack {
                Spacer()
                characterSection
                Spacer()
            }
            .frame(width: geometry.size.width * 0.25)

            VStack {
                Spacer()
                volumeVisualization
                playButton
                    .padding(.top, 24)
                Spacer()
            }
            .frame(width: geometry.size.width * 0.25)

            VStack {
                Spacer()
                answerButtonsGrid
                streakDisplay
                    .padding(.top, 16)
                Spacer()
            }
            .frame(width: geometry.size.width * 0.45)
        }
    }

    private func portraitLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            characterSection

            volumeVisualization

            playButton

            Spacer()

            answerButtonsGrid

            streakDisplay
        }
    }

    // MARK: - Character Section

    private var characterSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(viewModel.themeColor.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: viewModel.characterMood.systemImage)
                    .font(.system(size: 36))
                    .foregroundColor(viewModel.themeColor)
            }

            Text(viewModel.promptText)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Volume Visualization

    private var volumeVisualization: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(0..<6, id: \.self) { index in
                let height = CGFloat(20 + index * 15)
                let isActive = viewModel.hasPlayedAudio && !viewModel.hasAnswered

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        isActive
                            ? viewModel.themeColor.opacity(0.3 + Double(index) * 0.12)
                            : Color(.systemGray4)
                    )
                    .frame(width: 16, height: height)
            }
        }
        .frame(height: 100)
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasPlayedAudio)
    }

    // MARK: - Play Button

    private var playButton: some View {
        Button {
            if viewModel.hasPlayedAudio && !viewModel.hasAnswered {
                viewModel.replayAudio()
            } else {
                viewModel.playAudio()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(viewModel.themeColor)
                    .frame(width: 80, height: 80)
                    .shadow(color: viewModel.themeColor.opacity(0.3), radius: 10, y: 5)

                if viewModel.isPlaying {
                    DynamicsPlayingIndicator(color: .white)
                } else {
                    Image(systemName: viewModel.hasPlayedAudio ? "arrow.counterclockwise" : "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(!viewModel.canPlayAudio && !viewModel.hasPlayedAudio)
        .opacity(viewModel.hasAnswered ? 0.5 : 1)
        .accessibilityLabel(viewModel.hasPlayedAudio ? "Replay chord" : "Play chord")
    }

    // MARK: - Answer Buttons Grid (2x3)

    private var answerButtonsGrid: some View {
        let dynamics = viewModel.availableDynamics

        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(dynamics, id: \.self) { level in
                DynamicLevelButton(
                    dynamicLevel: level,
                    isSelected: viewModel.selectedAnswer == level,
                    isCorrect: viewModel.currentQuestion?.correctAnswer == level,
                    hasAnswered: viewModel.hasAnswered,
                    isDisabled: !viewModel.canSelectAnswer,
                    themeColor: viewModel.themeColor
                ) {
                    viewModel.selectAnswer(level)
                }
            }
        }
        .frame(maxWidth: 280)
    }

    // MARK: - Streak Display

    private var streakDisplay: some View {
        HStack(spacing: 12) {
            if viewModel.currentStreak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.appStreak)
                    Text("\(viewModel.currentStreak) streak")
                        .fontWeight(.semibold)
                        .foregroundColor(.appStreak)
                }
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.appStreak.opacity(0.15))
                )
            }
        }
        .frame(height: 32)
    }
}

// MARK: - Dynamic Level Button

private struct DynamicLevelButton: View {
    let dynamicLevel: DynamicLevel
    let isSelected: Bool
    let isCorrect: Bool
    let hasAnswered: Bool
    let isDisabled: Bool
    let themeColor: Color
    let action: () -> Void

    private var buttonColor: Color {
        if hasAnswered {
            if isCorrect {
                return .appSuccess
            } else if isSelected {
                return .appError
            }
        }
        return dynamicLevel.color
    }

    private var shouldHighlight: Bool {
        hasAnswered && isCorrect
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(buttonColor.opacity(isDisabled ? 0.3 : 1))
                        .frame(height: 60)
                        .shadow(
                            color: shouldHighlight ? buttonColor.opacity(0.5) : .clear,
                            radius: shouldHighlight ? 8 : 0
                        )

                    VStack(spacing: 2) {
                        Text(dynamicLevel.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .italic()

                        Text(dynamicLevel.englishDescription)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .disabled(isDisabled)
        .scaleEffect(isSelected && hasAnswered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .accessibilityLabel("\(dynamicLevel.italianName) - \(dynamicLevel.englishDescription)")
    }
}

// MARK: - Playing Indicator

private struct DynamicsPlayingIndicator: View {
    let color: Color

    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 6, height: isAnimating ? 24 : 12)
                    .animation(
                        .easeInOut(duration: 0.4)
                            .repeatForever()
                            .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Feedback Overlay

private struct DynamicsFeedbackOverlay: View {
    let isCorrect: Bool
    let dynamicLevel: DynamicLevel?
    let isVisible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(isVisible ? 0.3 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.2), value: isVisible)

            if isVisible {
                feedbackContent
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
            }
        }
        .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        .allowsHitTesting(false)
    }

    private var feedbackContent: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCorrect ? Color.appSuccess : Color.appError)
                    .frame(width: 100, height: 100)

                if isCorrect, let level = dynamicLevel {
                    Image(systemName: level.icon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "xmark")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            Text(isCorrect ? "Correct!" : "Not quite")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            if let level = dynamicLevel {
                VStack(spacing: 4) {
                    Text(level.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                        .italic()
                        .foregroundColor(.white)

                    Text(level.italianName)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}

// MARK: - Session Complete View

private struct DynamicsSessionCompleteView: View {
    @Bindable var viewModel: DynamicsViewModel
    let dismiss: DismissAction
    var onComplete: ((ExerciseResult) -> Void)?

    @State private var hasReportedCompletion = false
    @State private var showStars = false
    @State private var showContent = false

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            reportCompletion()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                showStars = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                showContent = true
            }
        }
    }

    private var portraitLayout: some View {
        VStack(spacing: 24) {
            Spacer()
            celebrationHeader
            statsCard
            Spacer()
            actionButtons
            Spacer()
                .frame(height: 20)
        }
        .padding(.horizontal, 24)
    }

    private var landscapeLayout: some View {
        HStack(spacing: 40) {
            VStack {
                Spacer()
                celebrationHeader
                Spacer()
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 24) {
                Spacer()
                statsCard
                actionButtons
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }

    private var celebrationHeader: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < viewModel.starRating ? "star.fill" : "star")
                        .font(.system(size: 52))
                        .foregroundColor(index < viewModel.starRating ? .appAccent : .secondary.opacity(0.3))
                        .scaleEffect(showStars ? 1.0 : 0.3)
                        .opacity(showStars ? 1.0 : 0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.6)
                                .delay(Double(index) * 0.15),
                            value: showStars
                        )
                }
            }

            Text(viewModel.completionMessage)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1 : 0)

            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(.appAccent)
                Text("+\(viewModel.sessionXP) XP")
                    .fontWeight(.bold)
                    .foregroundColor(.appAccent)
            }
            .font(.title2)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.appAccent.opacity(0.15))
            )
            .opacity(showContent ? 1 : 0)
        }
    }

    private var statsCard: some View {
        VStack(spacing: 14) {
            DynamicsStatRow(
                label: "Correct Answers",
                value: "\(viewModel.correctCount)/\(viewModel.totalQuestions)",
                icon: "checkmark.circle.fill",
                color: .appSuccess
            )
            Divider()
            DynamicsStatRow(
                label: "Accuracy",
                value: "\(viewModel.accuracyPercentage)%",
                icon: "percent",
                color: .appPrimary
            )
            Divider()
            DynamicsStatRow(
                label: "Best Streak",
                value: "\(viewModel.bestStreak)",
                icon: "flame.fill",
                color: .appStreak
            )
        }
        .padding(20)
        .frame(maxWidth: 320)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .opacity(showContent ? 1 : 0)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation {
                    showStars = false
                    showContent = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    viewModel.restartSession()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                        showStars = true
                    }
                    withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                        showContent = true
                    }
                }
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
                    .frame(height: 54)
                    .background(viewModel.themeColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(viewModel.themeColor)
                    .frame(maxWidth: 280)
                    .frame(height: 54)
            }
        }
        .opacity(showContent ? 1 : 0)
    }

    private func reportCompletion() {
        guard !hasReportedCompletion else { return }
        hasReportedCompletion = true

        let result = ExerciseResult(
            exerciseId: viewModel.exercise.id,
            chapterId: viewModel.exercise.chapterId,
            score: viewModel.accuracyPercentage,
            streak: viewModel.bestStreak,
            xpEarned: viewModel.sessionXP,
            passed: viewModel.accuracyPercentage >= Int(viewModel.exercise.passingScorePercent)
        )
        onComplete?(result)
    }
}

private struct DynamicsStatRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    var color: Color = .primary

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(color)
                    .frame(width: 24)
            }

            Text(label)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview

#Preview("Dynamics Exercise") {
    NavigationStack {
        DynamicsExerciseView(
            exercise: Exercise(
                _id: "preview",
                chapterId: "chapter1",
                config: """
                {"recognitionMode":"static","allowedDynamics":["pp","p","mp","mf","f","ff"],"numQuestions":5}
                """,
                difficulty: 1,
                exerciseTypeSlug: "dynamics",
                instructions: "Listen and identify how loud or soft the chord was played",
                isActive: true,
                name: "Loud & Soft - Level 1",
                passingScorePercent: 60,
                sortOrder: 1,
                xpReward: 10
            ),
            themeColor: Color(hex: "#7C3AED") ?? .purple
        )
    }
}
