//
//  AudioManager.swift
//  Intervals
//

import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @Published private(set) var isPlaying = false
    @Published var selectedInstrument: InstrumentType = .piano {
        didSet {
            if oldValue != selectedInstrument {
                updateEngine()
            }
        }
    }

    private var currentEngine: IntervalAudioEngineProtocol
    private var player: AVAudioPlayer?
    private var playbackCompletion: (() -> Void)?

    private init() {
        currentEngine = AudioEngineFactory.engine(for: .piano)
        configureAudioSession()
    }

    private func updateEngine() {
        print("AudioManager: Updating engine for \(selectedInstrument)")
        currentEngine.stop()
        currentEngine = AudioEngineFactory.engine(for: selectedInstrument)
    }

    /// Sync the audio engine with a user's preferred instrument
    func syncInstrument(with userProfile: UserProfile) {
        print("AudioManager: Syncing instrument to \(userProfile.preferredInstrument)")
        selectedInstrument = userProfile.preferredInstrument
    }

    private func configureAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        #endif
    }

    /// Play an interval using AudioKit tone generation
    /// - Parameters:
    ///   - semitones: Number of semitones for the interval
    ///   - rootNote: Optional MIDI note for consistent playback
    ///   - playMode: How to play (harmonic, melodic ascending, melodic descending)
    ///   - completion: Called when playback completes
    func playInterval(
        semitones: Int,
        rootNote: Int? = nil,
        playMode: IntervalPlayMode = .melodic,
        completion: (() -> Void)? = nil
    ) {
        guard !isPlaying else { return }

        isPlaying = true
        playbackCompletion = completion

        currentEngine.playInterval(semitones: semitones, rootNote: rootNote, playMode: playMode) { [weak self] in
            Task { @MainActor in
                self?.isPlaying = false
                self?.playbackCompletion?()
            }
        }
    }

    /// Play an interval from an IntervalType
    func playInterval(
        _ intervalType: IntervalType,
        rootNote: Int? = nil,
        playMode: IntervalPlayMode = .melodic,
        completion: (() -> Void)? = nil
    ) {
        playInterval(semitones: intervalType.semitones, rootNote: rootNote, playMode: playMode, completion: completion)
    }

    /// Legacy method for file-based playback (kept for compatibility)
    func playAudioFile(_ audioFileName: String, completion: (() -> Void)? = nil) {
        playbackCompletion = completion

        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: "mp3")
            ?? Bundle.main.url(forResource: audioFileName, withExtension: "wav")
            ?? Bundle.main.url(forResource: audioFileName, withExtension: "m4a")
        else {
            print("Audio file not found: \(audioFileName)")
            completion?()
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = AudioPlayerDelegate.shared
            AudioPlayerDelegate.shared.onFinish = { [weak self] in
                Task { @MainActor in
                    self?.isPlaying = false
                    self?.playbackCompletion?()
                }
            }
            isPlaying = true
            player?.play()
        } catch {
            print("Audio playback failed: \(error)")
            completion?()
        }
    }

    func stop() {
        currentEngine.stop()
        player?.stop()
        isPlaying = false
    }
}

private class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerDelegate()

    var onFinish: (() -> Void)?

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish?()
    }
}
