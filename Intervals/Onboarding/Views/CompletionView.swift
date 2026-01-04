//
//  CompletionView.swift
//  Intervals
//

import SwiftUI

struct CompletionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showConfetti = false
    @State private var mascotScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    @State private var starRotation: Double = 0

    var body: some View {
        ZStack {
            // Background confetti
            if showConfetti {
                ConfettiView()
            }

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Celebration elements
                        ZStack {
                            // Stars around mascot
                            ForEach(0..<5, id: \.self) { index in
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.yellow)
                                    .offset(
                                        x: cos(Double(index) * .pi * 2 / 5 + starRotation) * 60,
                                        y: sin(Double(index) * .pi * 2 / 5 + starRotation) * 60
                                    )
                                    .opacity(showConfetti ? 1 : 0)
                            }

                            // Mascot
                            OnboardingMascotView(pose: .celebrating, size: 100)
                                .scaleEffect(mascotScale)
                        }
                        .padding(.top, 32)

                        // Headline
                        Text(viewModel.headline(for: .completion))
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .opacity(textOpacity)

                        // Subtext
                        Text(viewModel.subtext(for: .completion))
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .opacity(textOpacity)
                    }
                    .padding(.bottom, 16)
                }
                .scrollBounceBehavior(.basedOnSize)

                // CTA Buttons - fixed at bottom
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.goToNext()
                    }) {
                        Text("Start practicing!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.appPrimary)
                            )
                    }

                    Button(action: {
                        viewModel.goToNext()
                    }) {
                        Text("Explore the app")
                            .font(.subheadline)
                            .foregroundStyle(Color.appPrimary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .opacity(textOpacity)
            }
        }
        .onAppear {
            startCelebration()
        }
    }

    private func startCelebration() {
        // Mascot bounce in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            mascotScale = 1.0
        }

        // Show confetti and stars
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                showConfetti = true
            }

            // Rotate stars
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                starRotation = .pi * 2
            }
        }

        // Fade in text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                textOpacity = 1.0
            }
        }

        // Play celebration sound (if sound enabled)
        playSuccessSound()
    }

    private func playSuccessSound() {
        // Sound would be implemented here respecting mute settings
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                animateParticles()
            }
        }
        .allowsHitTesting(false)
    }

    private func generateParticles(in size: CGSize) {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
        particles = (0..<50).map { _ in
            ConfettiParticle(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -50
                ),
                targetY: size.height + 50,
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...12),
                delay: Double.random(in: 0...1),
                opacity: 1.0
            )
        }
    }

    private func animateParticles() {
        for index in particles.indices {
            let particle = particles[index]
            DispatchQueue.main.asyncAfter(deadline: .now() + particle.delay) {
                withAnimation(.easeIn(duration: Double.random(in: 2...4))) {
                    particles[index].position.y = particle.targetY
                    particles[index].position.x += CGFloat.random(in: -100...100)
                    particles[index].opacity = 0
                }
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let targetY: CGFloat
    let color: Color
    let size: CGFloat
    let delay: Double
    var opacity: Double
}

#Preview {
    CompletionView(viewModel: OnboardingViewModel())
}
