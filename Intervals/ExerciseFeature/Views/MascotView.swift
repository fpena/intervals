//
//  MascotView.swift
//  Intervals
//

import SwiftUI

struct MascotView: View {
    let mood: ExerciseViewModel.MascotMood
    let promptText: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 16) {
            mascotImage
            speechBubble
        }
    }

    private var mascotImage: some View {
        ZStack {
            Circle()
                .fill(mood.color.opacity(0.15))
                .frame(width: 100, height: 100)

            Image(systemName: mood.systemImage)
                .font(.system(size: 48))
                .foregroundColor(mood.color)
                .transition(.scale.combined(with: .opacity))
                .animation(
                    reduceMotion ? .none : .easeInOut(duration: 0.3),
                    value: mood
                )
        }
        .accessibilityHidden(true)
    }

    private var speechBubble: some View {
        Text(promptText)
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            .accessibilityLabel(promptText)
    }
}

#Preview {
    HStack(spacing: 32) {
        MascotView(
            mood: .neutral,
            promptText: "Tap play to listen!"
        )

        MascotView(
            mood: .thinking,
            promptText: "What interval is this?"
        )

        MascotView(
            mood: .celebrating,
            promptText: "Great job!"
        )

        MascotView(
            mood: .encouraging,
            promptText: "Nice try! Keep going!"
        )
    }
    .padding()
}
