//
//  ExerciseViewModel.swift
//  Intervals
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class ExerciseViewModel {
    // MARK: - Session State

    private(set) var currentQuestionIndex: Int = 0
    let totalQuestions: Int
    private(set) var questions: [Question]
    private(set) var correctCount: Int = 0

    // MARK: - Current Question State

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    private(set) var selectedAnswer: String?
    private(set) var hasAnswered: Bool = false
    private(set) var isCorrect: Bool = false

    // MARK: - Audio State

    private(set) var isPlaying: Bool = false
    private(set) var hasPlayedAudio: Bool = false

    // MARK: - Gamification

    private(set) var currentStreak: Int = 0
    private(set) var sessionXP: Int = 0

    // MARK: - Mascot State

    private(set) var mascotMood: MascotMood = .neutral

    // MARK: - Feedback State

    private(set) var showFeedback: Bool = false

    // MARK: - Session Complete

    private(set) var isSessionComplete: Bool = false
    private(set) var sessionResult: SessionResult?

    // MARK: - Dependencies

    private let audioManager: AudioManager

    // MARK: - Constants

    private let baseXP = 10
    private let streakBonusXP = 5
    private let feedbackDuration: TimeInterval = 1.5

    // MARK: - Init

    init(
        questions: [Question] = Question.sampleIntervalQuestions,
        audioManager: AudioManager = .shared
    ) {
        self.questions = questions.shuffled()
        self.totalQuestions = questions.count
        self.audioManager = audioManager
    }

    // MARK: - Computed Properties

    var progress: Double {
        Double(currentQuestionIndex) / Double(totalQuestions)
    }

    var promptText: String {
        switch (hasPlayedAudio, hasAnswered) {
        case (false, false):
            return "Tap play to listen!"
        case (true, false):
            return "What interval is this?"
        case (_, true) where isCorrect:
            return correctResponses.randomElement() ?? "Great job!"
        case (_, true):
            return encouragingResponses.randomElement() ?? "Nice try! Keep going!"
        }
    }

    var canSelectAnswer: Bool {
        hasPlayedAudio && !hasAnswered
    }

    var canPlayAudio: Bool {
        !isPlaying && !hasAnswered
    }

    // MARK: - Response Variants

    private let correctResponses = [
        "Great job!",
        "Perfect!",
        "You got it!",
        "Excellent!",
        "Well done!"
    ]

    private let encouragingResponses = [
        "Nice try! Keep going!",
        "Almost there!",
        "Keep practicing!",
        "You'll get it next time!",
        "Good effort!"
    ]

    // MARK: - Actions

    func playAudio() {
        guard canPlayAudio, let question = currentQuestion else { return }

        isPlaying = true
        mascotMood = .listening

        // Use intervalType for AudioKit tone generation
        if let intervalType = question.intervalType {
            audioManager.playInterval(intervalType, rootNote: question.rootNote, playMode: .melodic) { [weak self] in
                Task { @MainActor in
                    self?.audioDidFinish()
                }
            }
        } else {
            // Fallback: simulate playback if no interval type
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                audioDidFinish()
            }
        }
    }

    private func audioDidFinish() {
        isPlaying = false
        hasPlayedAudio = true
        mascotMood = .thinking
    }

    func selectAnswer(_ answer: String) {
        guard canSelectAnswer else { return }

        selectedAnswer = answer
        hasAnswered = true
        isCorrect = answer == currentQuestion?.correctAnswer

        if isCorrect {
            correctCount += 1
            currentStreak += 1
            let bonus = currentStreak > 1 ? streakBonusXP * (currentStreak - 1) : 0
            sessionXP += baseXP + bonus
            mascotMood = .celebrating
        } else {
            currentStreak = 0
            mascotMood = .encouraging
        }

        triggerHapticFeedback()
        showFeedbackOverlay()
    }

    private func triggerHapticFeedback() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .medium : .rigid)
        generator.impactOccurred()
        #endif
    }

    private func showFeedbackOverlay() {
        showFeedback = true

        Task {
            try? await Task.sleep(for: .seconds(feedbackDuration))
            dismissFeedbackAndProceed()
        }
    }

    private func dismissFeedbackAndProceed() {
        showFeedback = false

        if currentQuestionIndex + 1 < totalQuestions {
            nextQuestion()
        } else {
            endSession()
        }
    }

    func nextQuestion() {
        currentQuestionIndex += 1
        resetQuestionState()
    }

    private func resetQuestionState() {
        selectedAnswer = nil
        hasAnswered = false
        isCorrect = false
        isPlaying = false
        hasPlayedAudio = false
        mascotMood = .neutral
    }

    func endSession() {
        sessionResult = SessionResult(
            totalQuestions: totalQuestions,
            correctAnswers: correctCount,
            xpEarned: sessionXP,
            newStreak: currentStreak,
            date: Date()
        )
        isSessionComplete = true
    }

    func restartSession() {
        currentQuestionIndex = 0
        correctCount = 0
        currentStreak = 0
        sessionXP = 0
        isSessionComplete = false
        sessionResult = nil
        questions = questions.shuffled()
        resetQuestionState()
    }
}

// MARK: - Mascot Mood

extension ExerciseViewModel {
    enum MascotMood: String {
        case neutral = "owl_neutral"
        case thinking = "owl_thinking"
        case celebrating = "owl_celebrating"
        case encouraging = "owl_encouraging"
        case listening = "owl_listening"

        var systemImage: String {
            switch self {
            case .neutral:
                return "face.smiling"
            case .thinking:
                return "face.dashed"
            case .celebrating:
                return "hands.clap.fill"
            case .encouraging:
                return "heart.fill"
            case .listening:
                return "ear.fill"
            }
        }

        var color: Color {
            switch self {
            case .neutral:
                return .appPrimary
            case .thinking:
                return .appSecondary
            case .celebrating:
                return .appSuccess
            case .encouraging:
                return .appAccent
            case .listening:
                return .appPrimary
            }
        }
    }
}
