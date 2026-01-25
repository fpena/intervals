//
//  AudioEngineFactory.swift
//  Intervals
//

import Foundation

/// Factory for creating audio engines based on instrument type
@MainActor
enum AudioEngineFactory {
    /// Cache of created engines to avoid recreating them
    private static var pianoEngine: PianoSamplerEngine?
    private static var oscillatorEngine: IntervalAudioEngine?

    /// Get or create an audio engine for the specified instrument
    /// - Parameter instrument: The instrument type to create an engine for
    /// - Returns: An audio engine conforming to IntervalAudioEngineProtocol
    static func engine(for instrument: InstrumentType) -> IntervalAudioEngineProtocol {
        switch instrument {
        case .piano:
            if pianoEngine == nil {
                pianoEngine = PianoSamplerEngine()
            }
            return pianoEngine!

        case .guitar, .violin, .flute, .clarinet:
            // Fall back to oscillator for instruments without samples yet
            if oscillatorEngine == nil {
                oscillatorEngine = IntervalAudioEngine.shared
            }
            return oscillatorEngine!
        }
    }

    /// Stop all engines
    static func stopAll() {
        pianoEngine?.stop()
        oscillatorEngine?.stop()
    }
}
