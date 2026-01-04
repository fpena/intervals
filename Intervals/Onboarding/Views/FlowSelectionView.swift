//
//  FlowSelectionView.swift
//  Intervals
//

import SwiftUI

struct FlowSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedFlow: SetupFlow?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // Mascot
                    OnboardingMascotView(pose: .wave, size: 100)
                        .padding(.top, 24)

                    // Headline
                    Text("Welcome! Who's setting up today?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // Options
                    VStack(spacing: 12) {
                        FlowOptionCard(
                            title: "I'm the learner",
                            subtitle: "I'll set up my own profile",
                            icon: "figure.wave",
                            isSelected: selectedFlow == .child
                        ) {
                            selectedFlow = .child
                            viewModel.setupFlow = .child
                        }

                        FlowOptionCard(
                            title: "I'm a parent/teacher",
                            subtitle: "I'm setting up for someone else",
                            icon: "figure.and.child.holdinghands",
                            isSelected: selectedFlow == .parent
                        ) {
                            selectedFlow = .parent
                            viewModel.setupFlow = .parent
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)
            }
            .scrollBounceBehavior(.basedOnSize)

            // CTA Button - fixed at bottom
            Button(action: {
                if selectedFlow != nil {
                    viewModel.goToNext()
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedFlow != nil ? Color.appPrimary : Color.gray.opacity(0.3))
                    )
            }
            .disabled(selectedFlow == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

struct FlowOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(isSelected ? Color.appPrimary : .secondary)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appPrimary)
                        .font(.title2)
                }
            }
            .padding()
            .frame(minHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    FlowSelectionView(viewModel: OnboardingViewModel())
}
