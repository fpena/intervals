//
//  AudioEngineProtocol.swift
//  Intervals
//

import Foundation

/// Protocol defining the interface for audio engines that can play intervals
@MainActor
protocol IntervalAudioEngineProtocol {
    /// Whether audio is currently playing
    var isPlaying: Bool { get }

    /// Play an interval with the given number of semitones
    /// - Parameters:
    ///   - semitones: Number of semitones (e.g., 3 for minor third, 4 for major third)
    ///   - playMode: How to play the interval (harmonic = together, melodic = sequential)
    ///   - completion: Called when playback finishes
    func playInterval(semitones: Int, playMode: IntervalPlayMode, completion: (() -> Void)?)

    /// Stop any currently playing audio
    func stop()
}
