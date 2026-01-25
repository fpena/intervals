//
//  PianoSamplerEngine.swift
//  Intervals
//

import AVFoundation
import Foundation

/// Audio engine that plays piano samples for interval exercises
@MainActor
final class PianoSamplerEngine: IntervalAudioEngineProtocol {
    private var players: [Int: AVAudioPlayer] = [:]  // Cache players by MIDI note
    private var activePlayers: [AVAudioPlayer] = []

    private(set) var isPlaying = false

    // MIDI note range for piano samples
    // File 001.aiff = MIDI 21 (A0), File 088.aiff = MIDI 108 (C8)
    private let midiNoteOffset = 20  // MIDI note = file number + 20
    private let lowestMidiNote = 21  // A0
    private let highestMidiNote = 108  // C8

    // Range for random root note selection (C3 to C5)
    private let rootNoteRangeLow = 48   // C3
    private let rootNoteRangeHigh = 72  // C5

    init() {
        print("PianoSamplerEngine: Initializing...")
        preloadSamples()
        print("PianoSamplerEngine: Preloaded \(players.count) samples")
    }

    /// Preload commonly used samples (C3-C5 range) for faster playback
    private func preloadSamples() {
        for midiNote in rootNoteRangeLow...(rootNoteRangeHigh + 12) {
            _ = player(for: midiNote)
        }
    }

    /// Get or create an AVAudioPlayer for the given MIDI note
    private func player(for midiNote: Int) -> AVAudioPlayer? {
        // Return cached player if available
        if let cachedPlayer = players[midiNote] {
            cachedPlayer.currentTime = 0
            return cachedPlayer
        }

        // Clamp to valid range
        let clampedNote = max(lowestMidiNote, min(highestMidiNote, midiNote))
        let fileNumber = clampedNote - midiNoteOffset
        let fileName = String(format: "%03d", fileNumber)

        // Try multiple paths (folder reference vs group)
        let url = Bundle.main.url(forResource: fileName, withExtension: "aiff", subdirectory: "Samples/Plano")
            ?? Bundle.main.url(forResource: fileName, withExtension: "aiff", subdirectory: "Plano")
            ?? Bundle.main.url(forResource: fileName, withExtension: "aiff")

        guard let url = url else {
            print("PianoSamplerEngine: Sample not found: \(fileName).aiff - checked Samples/Plano, Plano, and root")
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[midiNote] = player
            return player
        } catch {
            print("PianoSamplerEngine: Failed to create player for \(fileName).aiff: \(error)")
            return nil
        }
    }

    func playInterval(
        semitones: Int,
        playMode: IntervalPlayMode = .melodic,
        completion: (() -> Void)? = nil
    ) {
        print("PianoSamplerEngine: playInterval called - semitones: \(semitones), mode: \(playMode)")

        guard !isPlaying else {
            print("PianoSamplerEngine: Already playing, ignoring")
            completion?()
            return
        }

        isPlaying = true

        // Select random root note within comfortable range
        let rootNote = randomRootNote(forInterval: semitones)
        let intervalNote = rootNote + semitones

        switch playMode {
        case .harmonic:
            playHarmonic(rootNote: rootNote, intervalNote: intervalNote, completion: completion)
        case .melodic:
            playMelodic(firstNote: rootNote, secondNote: intervalNote, completion: completion)
        case .melodicDescending:
            playMelodic(firstNote: intervalNote, secondNote: rootNote, completion: completion)
        }
    }

    private func playHarmonic(rootNote: Int, intervalNote: Int, completion: (() -> Void)?) {
        activePlayers.removeAll()

        if let player1 = player(for: rootNote) {
            activePlayers.append(player1)
            player1.play()
        }

        if let player2 = player(for: intervalNote) {
            activePlayers.append(player2)
            player2.play()
        }

        Task {
            try? await Task.sleep(for: .seconds(3.0))
            stopAllNotes()
            isPlaying = false
            completion?()
        }
    }

    private func playMelodic(firstNote: Int, secondNote: Int, completion: (() -> Void)?) {
        activePlayers.removeAll()

        if let player1 = player(for: firstNote) {
            activePlayers.append(player1)
            player1.play()
        }

        Task {
            // Let first note ring naturally
            try? await Task.sleep(for: .seconds(1.8))
            stopAllNotes()

            // Brief pause between notes
            try? await Task.sleep(for: .seconds(0.2))

            if let player2 = player(for: secondNote) {
                activePlayers.append(player2)
                player2.play()
            }

            // Let second note ring
            try? await Task.sleep(for: .seconds(1.8))
            stopAllNotes()

            isPlaying = false
            completion?()
        }
    }

    private func stopAllNotes() {
        for player in activePlayers {
            player.stop()
            player.currentTime = 0
        }
        activePlayers.removeAll()
    }

    func stop() {
        stopAllNotes()
        isPlaying = false
    }

    /// Generate a random root note that keeps the interval within valid range
    private func randomRootNote(forInterval semitones: Int) -> Int {
        // Ensure the interval note stays within our sample range
        let maxRoot = min(rootNoteRangeHigh, highestMidiNote - semitones)
        let minRoot = max(rootNoteRangeLow, lowestMidiNote)

        guard maxRoot >= minRoot else {
            return rootNoteRangeLow
        }

        return Int.random(in: minRoot...maxRoot)
    }
}
