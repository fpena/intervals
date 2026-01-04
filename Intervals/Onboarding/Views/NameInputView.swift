//
//  NameInputView.swift
//  Intervals
//

import SwiftUI

struct NameInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isNameFocused: Bool
    @State private var showGreeting = false

    var body: some View {
        OnboardingScreenWrapper(viewModel: viewModel) {
            VStack(spacing: 24) {
                // Mascot
                OnboardingMascotView(pose: .thinking, size: 80)
                    .padding(.top, 24)

                // Headline
                Text(viewModel.headline(for: .nameInput))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Name input
                TextField(
                    viewModel.setupFlow == .child ? "Type your name..." : "Their first name...",
                    text: $viewModel.name
                )
                .font(.title3)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isNameFocused ? Color.appPrimary : Color.clear, lineWidth: 2)
                )
                .padding(.horizontal, 24)
                .focused($isNameFocused)

                // Validation hint
                if !viewModel.name.isEmpty && !viewModel.isNameValid {
                    Text("Please enter a valid name (letters only, max 20 characters)")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                // Greeting preview
                if viewModel.isNameValid && showGreeting {
                    Text("Nice to meet you, \(viewModel.name.trimmingCharacters(in: .whitespaces))!")
                        .font(.headline)
                        .foregroundStyle(Color.appPrimary)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
        .onChange(of: viewModel.name) { _, newValue in
            if viewModel.isNameValid {
                withAnimation(.spring(response: 0.3)) {
                    showGreeting = true
                }
            } else {
                showGreeting = false
            }
        }
    }
}

#Preview {
    NameInputView(viewModel: OnboardingViewModel())
}
