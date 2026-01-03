//
//  FeedbackOverlayView.swift
//  Intervals
//

import SwiftUI

struct FeedbackOverlayView: View {
    let isCorrect: Bool
    let isVisible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(isVisible ? 0.3 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.2), value: isVisible)

            if isVisible {
                feedbackContent
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
            }
        }
        .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        .allowsHitTesting(false)
    }

    private var feedbackContent: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCorrect ? Color.appSuccess : Color.appError)
                    .frame(width: 100, height: 100)

                Image(systemName: isCorrect ? "checkmark" : "xmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(isCorrect ? "Correct!" : "Not quite")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isCorrect ? "Correct answer" : "Incorrect answer")
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()

        VStack {
            Text("Background Content")
        }

        FeedbackOverlayView(isCorrect: true, isVisible: true)
    }
}

#Preview("Incorrect") {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()

        VStack {
            Text("Background Content")
        }

        FeedbackOverlayView(isCorrect: false, isVisible: true)
    }
}
