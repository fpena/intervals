//
//  PitchDirectionExerciseView.swift
//  Intervals
//

import SwiftUI

/// Result of completing an exercise
struct ExerciseResult {
    let exerciseId: String
    let chapterId: String
    let score: Int
    let streak: Int
    let xpEarned: Int
    let passed: Bool
}

struct PitchDirectionExerciseView: View {
    let exercise: Exercise
    let themeColor: Color
    var onComplete: ((ExerciseResult) -> Void)?

    @State private var viewModel: PitchDirectionViewModel?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let viewModel = viewModel {
                PitchDirectionGameContent(
                    viewModel: viewModel,
                    dismiss: dismiss,
                    onComplete: { result in
                        onComplete?(result)
                    }
                )
            } else {
                ProgressView()
                    .onAppear {
                        viewModel = PitchDirectionViewModel(
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

private struct PitchDirectionGameContent: View {
    @Bindable var viewModel: PitchDirectionViewModel
    let dismiss: DismissAction
    var onComplete: ((ExerciseResult) -> Void)?

    var body: some View {
        ZStack {
            // Background gradient with garden theme
            gardenBackground

            VStack(spacing: 0) {
                if viewModel.isSessionComplete {
                    SessionCompleteView(
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
            PitchFeedbackOverlay(
                isCorrect: viewModel.isCorrect,
                direction: viewModel.currentQuestion?.correctAnswer,
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
            // Progress dots
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
            // Left - Character and prompt
            VStack {
                Spacer()
                characterSection
                Spacer()
            }
            .frame(width: geometry.size.width * 0.3)

            // Center - Play button and staircase visualization
            VStack {
                Spacer()
                staircaseVisualization
                playButton
                    .padding(.top, 24)
                Spacer()
            }
            .frame(width: geometry.size.width * 0.3)

            // Right - Answer buttons
            VStack {
                Spacer()
                answerButtons
                streakDisplay
                    .padding(.top, 16)
                Spacer()
            }
            .frame(width: geometry.size.width * 0.35)
        }
    }

    private func portraitLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            characterSection

            staircaseVisualization

            playButton

            Spacer()

            answerButtons

            streakDisplay
        }
    }

    // MARK: - Character Section

    private var characterSection: some View {
        VStack(spacing: 16) {
            // Character avatar (Mozart placeholder)
            ZStack {
                Circle()
                    .fill(viewModel.themeColor.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: viewModel.characterMood.systemImage)
                    .font(.system(size: 36))
                    .foregroundColor(viewModel.themeColor)
            }

            // Speech bubble
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

    // MARK: - Staircase Visualization

    private var staircaseVisualization: some View {
        ZStack {
            // Staircase graphic
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    let height = CGFloat(30 + index * 20)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            index == 2
                                ? viewModel.themeColor
                                : viewModel.themeColor.opacity(0.3)
                        )
                        .frame(width: 24, height: height)
                }
            }
            .opacity(viewModel.hasPlayedAudio && !viewModel.hasAnswered ? 1 : 0.5)
        }
        .frame(height: 120)
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
                    // Animated playing indicator
                    PlayingIndicator(color: .white)
                } else {
                    Image(systemName: viewModel.hasPlayedAudio ? "arrow.counterclockwise" : "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(!viewModel.canPlayAudio && !viewModel.hasPlayedAudio)
        .opacity(viewModel.hasAnswered ? 0.5 : 1)
        .accessibilityLabel(viewModel.hasPlayedAudio ? "Replay notes" : "Play notes")
    }

    // MARK: - Answer Buttons

    private var answerButtons: some View {
        HStack(spacing: 24) {
            // Lower button (left side per spec)
            DirectionButton(
                direction: .lower,
                isSelected: viewModel.selectedAnswer == .lower,
                isCorrect: viewModel.currentQuestion?.correctAnswer == .lower,
                hasAnswered: viewModel.hasAnswered,
                isDisabled: !viewModel.canSelectAnswer,
                themeColor: viewModel.themeColor
            ) {
                viewModel.selectAnswer(.lower)
            }

            // Higher button (right side per spec)
            DirectionButton(
                direction: .higher,
                isSelected: viewModel.selectedAnswer == .higher,
                isCorrect: viewModel.currentQuestion?.correctAnswer == .higher,
                hasAnswered: viewModel.hasAnswered,
                isDisabled: !viewModel.canSelectAnswer,
                themeColor: viewModel.themeColor
            ) {
                viewModel.selectAnswer(.higher)
            }
        }
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

// MARK: - Direction Button

private struct DirectionButton: View {
    let direction: PitchDirection
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
        return direction == .higher ? .appSuccess : themeColor
    }

    private var shouldHighlight: Bool {
        hasAnswered && isCorrect
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(buttonColor.opacity(isDisabled ? 0.3 : 1))
                        .frame(width: 100, height: 100)
                        .shadow(
                            color: shouldHighlight ? buttonColor.opacity(0.5) : .clear,
                            radius: shouldHighlight ? 10 : 0
                        )

                    Image(systemName: direction.icon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }

                Text(direction.displayName)
                    .font(.headline)
                    .foregroundColor(isDisabled ? .secondary : .primary)
            }
        }
        .disabled(isDisabled)
        .scaleEffect(isSelected && hasAnswered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .accessibilityLabel("\(direction.displayName) - Second note is \(direction.displayName.lowercased())")
    }
}

// MARK: - Playing Indicator

private struct PlayingIndicator: View {
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

private struct PitchFeedbackOverlay: View {
    let isCorrect: Bool
    let direction: PitchDirection?
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

                if isCorrect, let direction = direction {
                    Image(systemName: direction.icon)
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

            if !isCorrect, let direction = direction {
                Text("It was \(direction.displayName.uppercased())")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Session Complete View

private struct SessionCompleteView: View {
    @Bindable var viewModel: PitchDirectionViewModel
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

    // MARK: - Portrait Layout

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

    // MARK: - Landscape Layout

    private var landscapeLayout: some View {
        HStack(spacing: 40) {
            // Left side - celebration
            VStack {
                Spacer()
                celebrationHeader
                Spacer()
            }
            .frame(maxWidth: .infinity)

            // Right side - stats and buttons
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

    // MARK: - Celebration Header

    private var celebrationHeader: some View {
        VStack(spacing: 20) {
            // Animated stars
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

            // Completion message
            Text(viewModel.completionMessage)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1 : 0)

            // XP earned badge
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

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(spacing: 14) {
            StatRow(
                label: "Correct Answers",
                value: "\(viewModel.correctCount)/\(viewModel.totalQuestions)",
                icon: "checkmark.circle.fill",
                color: .appSuccess
            )
            Divider()
            StatRow(
                label: "Accuracy",
                value: "\(viewModel.accuracyPercentage)%",
                icon: "percent",
                color: .appPrimary
            )
            Divider()
            StatRow(
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

    // MARK: - Action Buttons

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

    // MARK: - Report Completion

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

private struct StatRow: View {
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

#Preview("Pitch Direction Exercise") {
    NavigationStack {
        PitchDirectionExerciseView(
            exercise: Exercise(
                _id: "preview",
                chapterId: "chapter1",
                config: """
                {"minIntervalSemitones":7,"maxIntervalSemitones":12,"noteRangeLow":"C4","noteRangeHigh":"C6","numQuestions":5}
                """,
                difficulty: 1,
                exerciseTypeSlug: "pitch_direction",
                instructions: "Listen and identify if the second note is higher or lower",
                isActive: true,
                name: "High & Low - Level 1",
                passingScorePercent: 60,
                sortOrder: 1,
                xpReward: 10
            ),
            themeColor: Color(hex: "#7C3AED") ?? .purple
        )
    }
}
