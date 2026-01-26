//
//  PitchDirectionViewModel.swift
//  Intervals
//

import Foundation
import SwiftUI

// MARK: - Pitch Direction Question

struct PitchDirectionQuestion: Identifiable {
    let id = UUID()
    let note1MidiNote: Int
    let note2MidiNote: Int

    var correctAnswer: PitchDirection {
        note2MidiNote > note1MidiNote ? .higher : .lower
    }

    var intervalSemitones: Int {
        abs(note2MidiNote - note1MidiNote)
    }
}

enum PitchDirection: String, CaseIterable {
    case higher
    case lower

    var displayName: String {
        switch self {
        case .higher: return "Higher"
        case .lower: return "Lower"
        }
    }

    var icon: String {
        switch self {
        case .higher: return "arrow.up"
        case .lower: return "arrow.down"
        }
    }

    var color: Color {
        switch self {
        case .higher: return .appSuccess
        case .lower: return .appError
        }
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class PitchDirectionViewModel {
    // MARK: - Configuration

    let exercise: Exercise
    let themeColor: Color
    private let config: PitchDirectionConfig

    // MARK: - Session State

    private(set) var currentQuestionIndex: Int = 0
    private(set) var questions: [PitchDirectionQuestion] = []
    private(set) var correctCount: Int = 0

    var totalQuestions: Int { config.numQuestions }

    // MARK: - Current Question State

    var currentQuestion: PitchDirectionQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    private(set) var selectedAnswer: PitchDirection?
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
    private let noteDuration: TimeInterval = 0.8
    private let noteGap: TimeInterval = 0.5

    // MARK: - Child-Friendly Responses

    private let correctResponses = [
        "You got it!",
        "Amazing ears!",
        "Mozart would be proud!",
        "Perfect listening!",
        "You're a star!"
    ]

    private let incorrectResponses = [
        "Not quite - let's hear it again!",
        "Almost! Listen to the difference...",
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
        if let parsed = PitchDirectionConfig.parse(from: exercise.config) {
            self.config = parsed
        } else {
            self.config = .defaultConfig
        }

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
            return "Is the second note HIGHER or LOWER?"
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

    // MARK: - Question Generation

    private func generateQuestions() {
        let lowMidi = NoteParsing.midiNote(from: config.noteRangeLow) ?? 60  // C4
        let highMidi = NoteParsing.midiNote(from: config.noteRangeHigh) ?? 84 // C6

        questions = (0..<config.numQuestions).map { _ in
            generateQuestion(lowMidi: lowMidi, highMidi: highMidi)
        }
    }

    private func generateQuestion(lowMidi: Int, highMidi: Int) -> PitchDirectionQuestion {
        // Pick random starting note
        let note1 = Int.random(in: lowMidi...highMidi)

        // Pick random interval
        let interval = Int.random(in: config.minIntervalSemitones...config.maxIntervalSemitones)

        // Randomly decide direction
        let goingUp = Bool.random()

        // Calculate second note
        var note2 = goingUp ? note1 + interval : note1 - interval

        // Ensure note2 stays within playable range
        if note2 > highMidi {
            note2 = note1 - interval  // Flip to going down
        } else if note2 < lowMidi {
            note2 = note1 + interval  // Flip to going up
        }

        return PitchDirectionQuestion(
            note1MidiNote: note1,
            note2MidiNote: note2
        )
    }

    // MARK: - Audio Playback

    func playAudio() {
        guard canPlayAudio, let question = currentQuestion else { return }

        isPlaying = true
        characterMood = .listening

        // Play two notes sequentially
        playTwoNotes(note1: question.note1MidiNote, note2: question.note2MidiNote)
    }

    private func playTwoNotes(note1: Int, note2: Int) {
        // Calculate interval from note1 to note2
        let semitones = note2 - note1
        let isAscending = semitones > 0

        audioManager.playInterval(
            semitones: abs(semitones),
            rootNote: isAscending ? note1 : note2,
            playMode: isAscending ? .melodic : .melodicDescending
        ) { [weak self] in
            Task { @MainActor in
                self?.audioDidFinish()
            }
        }
    }

    func replayAudio() {
        guard !isPlaying, let question = currentQuestion else { return }

        isPlaying = true
        playTwoNotes(note1: question.note1MidiNote, note2: question.note2MidiNote)
    }

    private func audioDidFinish() {
        isPlaying = false
        hasPlayedAudio = true
        characterMood = .thinking
    }

    // MARK: - Answer Selection

    func selectAnswer(_ answer: PitchDirection) {
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
