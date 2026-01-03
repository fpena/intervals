//
//  ScoreDisplayView.swift
//  Intervals
//

import SwiftUI

struct ScoreDisplayView: View {
    let streak: Int
    let xp: Int

    @State private var animatedStreak: Int = 0
    @State private var animatedXP: Int = 0

    var body: some View {
        HStack(spacing: 24) {
            streakDisplay
            xpDisplay
        }
        .onChange(of: streak) { _, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                animatedStreak = newValue
            }
        }
        .onChange(of: xp) { _, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                animatedXP = newValue
            }
        }
        .onAppear {
            animatedStreak = streak
            animatedXP = xp
        }
    }

    private var streakDisplay: some View {
        HStack(spacing: 6) {
            Text("🔥")
                .font(.title2)

            Text("\(animatedStreak)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appStreak)
                .contentTransition(.numericText())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(animatedStreak) streak")
    }

    private var xpDisplay: some View {
        HStack(spacing: 6) {
            Text("⭐")
                .font(.title2)

            Text("\(animatedXP)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appAccent)
                .contentTransition(.numericText())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(animatedXP) experience points")
    }
}

#Preview {
    VStack(spacing: 32) {
        ScoreDisplayView(streak: 0, xp: 0)
        ScoreDisplayView(streak: 3, xp: 45)
        ScoreDisplayView(streak: 10, xp: 150)
    }
    .padding()
}
