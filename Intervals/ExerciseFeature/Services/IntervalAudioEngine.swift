//
//  IntervalAudioEngine.swift
//  Intervals
//

import AudioKit
import AVFoundation
import Foundation

@MainActor
final class IntervalAudioEngine {
    static let shared = IntervalAudioEngine()

    private let engine = AudioEngine()
    private var oscillator1: PlaygroundOscillator?
    private var oscillator2: PlaygroundOscillator?
    private var mixer: Mixer?

    private(set) var isPlaying = false

    // Base frequency for middle C (C4)
    private let baseFrequency: Float = 261.63

    private init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        oscillator1 = PlaygroundOscillator(waveform: Table(.sine), frequency: baseFrequency, amplitude: 0.5)
        oscillator2 = PlaygroundOscillator(waveform: Table(.sine), frequency: baseFrequency, amplitude: 0.5)

        guard let osc1 = oscillator1, let osc2 = oscillator2 else { return }

        mixer = Mixer(osc1, osc2)
        engine.output = mixer

        do {
            try engine.start()
        } catch {
            print("AudioKit engine failed to start: \(error)")
        }
    }

    /// Play an interval with the given number of semitones
    /// - Parameters:
    ///   - semitones: Number of semitones (e.g., 3 for minor third, 4 for major third)
    ///   - playMode: How to play the interval (harmonic = together, melodic = sequential)
    ///   - completion: Called when playback finishes
    func playInterval(
        semitones: Int,
        playMode: IntervalPlayMode = .melodic,
        completion: (() -> Void)? = nil
    ) {
        guard !isPlaying else { return }

        isPlaying = true

        // Calculate frequencies
        let rootFrequency = randomRootFrequency()
        let intervalFrequency = frequencyForSemitones(semitones, from: rootFrequency)

        oscillator1?.frequency = rootFrequency
        oscillator2?.frequency = intervalFrequency

        switch playMode {
        case .harmonic:
            playHarmonic(completion: completion)
        case .melodic:
            playMelodic(completion: completion)
        case .melodicDescending:
            playMelodicDescending(completion: completion)
        }
    }

    private func playHarmonic(completion: (() -> Void)?) {
        oscillator1?.start()
        oscillator2?.start()

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            oscillator1?.stop()
            oscillator2?.stop()
            isPlaying = false
            completion?()
        }
    }

    private func playMelodic(completion: (() -> Void)?) {
        // Play root note first
        oscillator1?.start()

        Task {
            try? await Task.sleep(for: .seconds(0.6))
            oscillator1?.stop()

            // Small gap between notes
            try? await Task.sleep(for: .seconds(0.1))

            // Play interval note
            oscillator2?.start()

            try? await Task.sleep(for: .seconds(0.6))
            oscillator2?.stop()

            isPlaying = false
            completion?()
        }
    }

    private func playMelodicDescending(completion: (() -> Void)?) {
        // Play interval note first (higher)
        oscillator2?.start()

        Task {
            try? await Task.sleep(for: .seconds(0.6))
            oscillator2?.stop()

            // Small gap between notes
            try? await Task.sleep(for: .seconds(0.1))

            // Play root note (lower)
            oscillator1?.start()

            try? await Task.sleep(for: .seconds(0.6))
            oscillator1?.stop()

            isPlaying = false
            completion?()
        }
    }

    func stop() {
        oscillator1?.stop()
        oscillator2?.stop()
        isPlaying = false
    }

    /// Generate a random root frequency within a comfortable range (C3 to C5)
    private func randomRootFrequency() -> Float {
        // C3 = 130.81 Hz, C5 = 523.25 Hz
        // Use semitones from C3 (0) to C5 (24)
        let randomSemitones = Int.random(in: 0...24)
        return frequencyForSemitones(randomSemitones, from: 130.81)
    }

    /// Calculate frequency for a given number of semitones from a base frequency
    private func frequencyForSemitones(_ semitones: Int, from baseFreq: Float) -> Float {
        // f = f0 * 2^(n/12)
        return baseFreq * pow(2.0, Float(semitones) / 12.0)
    }
}

// MARK: - Play Mode

enum IntervalPlayMode {
    case harmonic       // Both notes played together
    case melodic        // Root note first, then interval (ascending)
    case melodicDescending  // Interval note first, then root (descending)
}

// MARK: - Interval Semitones

extension IntervalType {
    var semitones: Int {
        switch self {
        case .minorSecond: return 1
        case .majorSecond: return 2
        case .minorThird: return 3
        case .majorThird: return 4
        case .perfectFourth: return 5
        case .tritone: return 6
        case .perfectFifth: return 7
        case .minorSixth: return 8
        case .majorSixth: return 9
        case .minorSeventh: return 10
        case .majorSeventh: return 11
        case .octave: return 12
        }
    }

    static func fromSemitones(_ semitones: Int) -> IntervalType? {
        allCases.first { $0.semitones == semitones }
    }
}
