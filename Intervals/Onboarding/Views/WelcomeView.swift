//
//  WelcomeView.swift
//  Intervals
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showMascot = false
    @State private var showText = false
    @State private var floatingOffset: CGFloat = 0

    var body: some View {
        OnboardingScreenWrapper(viewModel: viewModel, showBackButton: true, showSkipButton: true) {
            VStack(spacing: 24) {
                // Mascot with animation
                ZStack {
                    // Floating musical notes
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "music.note")
                            .font(.title)
                            .foregroundStyle(Color.appPrimary.opacity(0.5))
                            .offset(
                                x: CGFloat(index - 1) * 60,
                                y: floatingOffset + CGFloat(index) * 10
                            )
                    }

                    OnboardingMascotView(
                        pose: viewModel.setupFlow == .child ? .celebrating : .neutral,
                        size: 120
                    )
                    .scaleEffect(showMascot ? 1 : 0.5)
                    .opacity(showMascot ? 1 : 0)
                }
                .padding(.top, 24)
                .padding(.bottom, 16)

                // Headline
                Text(viewModel.headline(for: .welcome))
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)

                // Subtext
                Text(viewModel.subtext(for: .welcome))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showMascot = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showText = true
            }
            startFloatingAnimation()
        }
    }

    private func startFloatingAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            floatingOffset = -15
        }
    }
}

#Preview {
    WelcomeView(viewModel: OnboardingViewModel())
}
