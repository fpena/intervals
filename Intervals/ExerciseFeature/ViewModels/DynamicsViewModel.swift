//
//  DynamicsViewModel.swift
//  Intervals
//

import Foundation
import SwiftUI

// MARK: - ViewModel

@MainActor
@Observable
final class DynamicsViewModel {
    // MARK: - Configuration

    let exercise: Exercise
    let themeColor: Color
    private let config: DynamicsConfig
    private let allowedDynamics: [DynamicLevel]

    // MARK: - Session State

    private(set) var currentQuestionIndex: Int = 0
    private(set) var questions: [DynamicsQuestion] = []
    private(set) var correctCount: Int = 0

    var totalQuestions: Int { config.numQuestions }

    // MARK: - Current Question State

    var currentQuestion: DynamicsQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    private(set) var selectedAnswer: DynamicLevel?
    private(set) var hasAnswered: Bool = false
    private(set) var isCorrect: Bool = false

    // MARK: - Audio State

    private(set) var isPlaying: Bool = false
    private(set) var hasPlayedAudio: Bool = false

    // MARK: - Gamification

    private(set) var currentStreak: Int = 0
    private(set) var sessionXP: Int = 0
    private(set) var bestStreak: Int = 0

    // MARK: - Character State

    enum CharacterMood: String {
        case neutral
        case listening
        case thinking
        case celebrating
        case encouraging

        var systemImage: String {
            switch self {
            case .neutral: return "face.smiling"
            case .listening: return "ear.fill"
            case .thinking: return "questionmark.circle"
            case .celebrating: return "hands.clap.fill"
            case .encouraging: return "heart.fill"
            }
        }
    }

    private(set) var characterMood: CharacterMood = .neutral

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
    private let feedbackDuration: TimeInterval = 1.2

    // Note range for chord generation
    private let noteRangeLow: Int
    private let noteRangeHigh: Int

    // MARK: - Child-Friendly Responses

    private let correctResponses = [
        "You got it!",
        "Amazing ears!",
        "Great listening!",
        "Perfect!",
        "You're a star!"
    ]

    private let incorrectResponses = [
        "Not quite - let's hear it again!",
        "Almost! Listen to the volume...",
        "Tricky one! Try again!",
        "Good try! Keep practicing!"
    ]

    private let completionMessages: [(range: ClosedRange<Int>, message: String)] = [
        (100...100, "PERFECT! You have amazing ears!"),
        (80...99, "Great job! You're really learning!"),
        (70...79, "Good work! Keep practicing!"),
        (0...69, "Nice try! Let's practice more!")
    ]

    // MARK: - Init

    init(
        exercise: Exercise,
        themeColor: Color = .appPrimary,
        audioManager: AudioManager = .shared
    ) {
        self.exercise = exercise
        self.themeColor = themeColor
        self.audioManager = audioManager

        // Parse config from exercise
        if let parsed = DynamicsConfig.parse(from: exercise.config) {
            self.config = parsed
        } else {
            self.config = .defaultConfig
        }

        // Parse allowed dynamics from config
        self.allowedDynamics = DynamicLevel.dynamics(from: config.allowedDynamics)
            .isEmpty ? DynamicLevel.allCases : DynamicLevel.dynamics(from: config.allowedDynamics)

        // Parse note range (defaults to C3-C5)
        self.noteRangeLow = NoteParsing.midiNote(from: config.noteRangeLow ?? "C3") ?? 48
        self.noteRangeHigh = NoteParsing.midiNote(from: config.noteRangeHigh ?? "C5") ?? 72

        generateQuestions()
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
            return "How loud was that?"
        case (_, true) where isCorrect:
            return correctResponses.randomElement() ?? "Great job!"
        case (_, true):
            return incorrectResponses.randomElement() ?? "Nice try!"
        }
    }

    var canSelectAnswer: Bool {
        hasPlayedAudio && !hasAnswered && !isPlaying
    }

    var canPlayAudio: Bool {
        !isPlaying && !hasAnswered
    }

    var accuracyPercentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(correctCount) / Double(totalQuestions)) * 100)
    }

    var completionMessage: String {
        let accuracy = accuracyPercentage
        return completionMessages.first { $0.range.contains(accuracy) }?.message ?? "Great effort!"
    }

    var starRating: Int {
        switch accuracyPercentage {
        case 90...100: return 3
        case 70..<90: return 2
        case 50..<70: return 1
        default: return 0
        }
    }

    /// Available dynamic levels for answer buttons
    var availableDynamics: [DynamicLevel] {
        allowedDynamics.sorted { $0.volumeLevel < $1.volumeLevel }
    }

    // MARK: - Question Generation

    private func generateQuestions() {
        questions = (0..<config.numQuestions).map { _ in
            generateQuestion()
        }
    }

    private func generateQuestion() -> DynamicsQuestion {
        // Generate a random major triad
        let chordNotes = generateMajorTriad()

        // Pick a random dynamic level from allowed dynamics
        let dynamicLevel = allowedDynamics.randomElement() ?? .mf

        return DynamicsQuestion(
            chordNotes: chordNotes,
            correctAnswer: dynamicLevel
        )
    }

    /// Generate a major triad starting from a random root note
    private func generateMajorTriad() -> [Int] {
        // Pick a random root note within the configured range
        let root = Int.random(in: noteRangeLow...(noteRangeHigh - 7))

        // Major triad: root, major third (+4 semitones), perfect fifth (+7 semitones)
        return [root, root + 4, root + 7]
    }

    // MARK: - Audio Playback

    func playAudio() {
        guard canPlayAudio, let question = currentQuestion else { return }

        isPlaying = true
        characterMood = .listening

        audioManager.playChord(notes: question.chordNotes, volume: question.volume) { [weak self] in
            Task { @MainActor in
                self?.audioDidFinish()
            }
        }
    }

    func replayAudio() {
        guard !isPlaying, let question = currentQuestion else { return }

        isPlaying = true
        audioManager.playChord(notes: question.chordNotes, volume: question.volume) { [weak self] in
            Task { @MainActor in
                self?.isPlaying = false
            }
        }
    }

    private func audioDidFinish() {
        isPlaying = false
        hasPlayedAudio = true
        characterMood = .thinking
    }

    // MARK: - Answer Selection

    func selectAnswer(_ answer: DynamicLevel) {
        guard canSelectAnswer, let question = currentQuestion else { return }

        selectedAnswer = answer
        hasAnswered = true
        isCorrect = answer == question.correctAnswer

        if isCorrect {
            correctCount += 1
            currentStreak += 1
            bestStreak = max(bestStreak, currentStreak)
            let bonus = currentStreak > 1 ? streakBonusXP * (currentStreak - 1) : 0
            sessionXP += baseXP + bonus
            characterMood = .celebrating
        } else {
            currentStreak = 0
            characterMood = .encouraging
        }

        triggerHapticFeedback()
        showFeedbackOverlay()
    }

    private func triggerHapticFeedback() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .medium : .light)
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

    // MARK: - Navigation

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
        characterMood = .neutral
    }

    func endSession() {
        sessionResult = SessionResult(
            totalQuestions: totalQuestions,
            correctAnswers: correctCount,
            xpEarned: sessionXP,
            newStreak: bestStreak,
            date: Date()
        )
        isSessionComplete = true
    }

    func restartSession() {
        currentQuestionIndex = 0
        correctCount = 0
        currentStreak = 0
        bestStreak = 0
        sessionXP = 0
        isSessionComplete = false
        sessionResult = nil
        generateQuestions()
        resetQuestionState()
    }
}
