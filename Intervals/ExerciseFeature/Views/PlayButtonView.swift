//
//  PlayButtonView.swift
//  Intervals
//

import SwiftUI

struct PlayButtonView: View {
    let isPlaying: Bool
    let hasPlayedAudio: Bool
    let isDisabled: Bool
    let onPlay: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 12) {
            mainPlayButton

            if hasPlayedAudio && !isDisabled {
                replayButton
            } else {
                hintText
            }
        }
    }

    private var mainPlayButton: some View {
        Button(action: onPlay) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.appPrimary, .appSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(Shadow.colored(.appPrimary))

                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: isPlaying ? 0 : 3)
            }
            .scaleEffect(pulseScale)
            .animation(pulseAnimation, value: isPlaying)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .accessibilityLabel(isPlaying ? "Pause" : "Play the interval")
        .accessibilityHint(
            isPlaying
                ? "Double tap to pause"
                : "Double tap to hear the musical interval"
        )
    }

    private var pulseScale: CGFloat {
        guard !reduceMotion else { return 1.0 }
        return isPlaying ? 1.1 : 1.0
    }

    private var pulseAnimation: Animation? {
        guard !reduceMotion, isPlaying else { return .default }
        return .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
    }

    private var hintText: some View {
        Text("Tap to listen")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .opacity(isDisabled ? 0.5 : 1.0)
            .accessibilityHidden(true)
    }

    private var replayButton: some View {
        Button(action: onPlay) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.clockwise")
                Text("Replay")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.appPrimary)
        }
        .accessibilityLabel("Replay the interval")
        .accessibilityHint("Double tap to hear the interval again")
    }
}

#Preview {
    VStack(spacing: 48) {
        PlayButtonView(
            isPlaying: false,
            hasPlayedAudio: false,
            isDisabled: false,
            onPlay: {}
        )

        PlayButtonView(
            isPlaying: true,
            hasPlayedAudio: false,
            isDisabled: false,
            onPlay: {}
        )

        PlayButtonView(
            isPlaying: false,
            hasPlayedAudio: true,
            isDisabled: false,
            onPlay: {}
        )

        PlayButtonView(
            isPlaying: false,
            hasPlayedAudio: true,
            isDisabled: true,
            onPlay: {}
        )
    }
    .padding()
}
