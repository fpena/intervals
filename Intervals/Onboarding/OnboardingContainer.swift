//
//  OnboardingContainer.swift
//  Intervals
//

import SwiftUI
import SwiftData

struct OnboardingContainer: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var user: UserProfile?
    var onComplete: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Progress indicator (hidden on flow selection)
                if viewModel.currentScreen != .flowSelection {
                    OnboardingProgressBar(progress: viewModel.progress)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }

                // Main content
                screenContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(.systemBackground))
        }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete {
                finishOnboarding()
            }
        }
    }

    @ViewBuilder
    private var screenContent: some View {
        switch viewModel.currentScreen {
        case .flowSelection:
            FlowSelectionView(viewModel: viewModel)
        case .welcome:
            WelcomeView(viewModel: viewModel)
        case .nameInput:
            NameInputView(viewModel: viewModel)
        case .ageSelection:
            AgeSelectionView(viewModel: viewModel)
        case .instrumentSelection:
            InstrumentSelectionView(viewModel: viewModel)
        case .gradeSelection:
            GradeSelectionView(viewModel: viewModel)
        case .goalSelection:
            GoalSelectionView(viewModel: viewModel)
        case .reminderSetup:
            ReminderSetupView(viewModel: viewModel)
        case .completion:
            CompletionView(viewModel: viewModel)
        }
    }

    private func finishOnboarding() {
        let profile: UserProfile
        if let existingUser = user {
            profile = existingUser
        } else {
            profile = UserProfile()
            modelContext.insert(profile)
            user = profile
        }

        viewModel.saveToProfile(profile, modelContext: modelContext)
        onComplete()
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)

                // Progress fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appPrimary)
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Shared Components

struct OnboardingScreenWrapper<Content: View>: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let showBackButton: Bool
    let showSkipButton: Bool
    @ViewBuilder let content: () -> Content

    init(
        viewModel: OnboardingViewModel,
        showBackButton: Bool = true,
        showSkipButton: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.viewModel = viewModel
        self.showBackButton = showBackButton
        self.showSkipButton = showSkipButton
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                if showBackButton && viewModel.currentScreen != .flowSelection && viewModel.currentScreen != .welcome {
                    Button(action: viewModel.goBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(Color.appPrimary)
                    }
                    .padding(.leading)
                }

                Spacer()

                if showSkipButton {
                    Button("Skip for now") {
                        viewModel.skipOnboarding()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.trailing)
                }
            }
            .frame(height: 44)

            // Screen content - scrollable
            ScrollView {
                content()
                    .padding(.bottom, 16)
            }
            .scrollBounceBehavior(.basedOnSize)

            // CTA Button - fixed at bottom
            Button(action: viewModel.goToNext) {
                Text(viewModel.ctaText(for: viewModel.currentScreen))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(viewModel.canProceed ? Color.appPrimary : Color.gray.opacity(0.3))
                    )
            }
            .disabled(!viewModel.canProceed)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Option Card

struct OptionCard<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            HStack {
                content()
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appPrimary)
                        .font(.title2)
                }
            }
            .padding()
            .frame(minHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Onboarding Mascot View

struct OnboardingMascotView: View {
    enum Pose {
        case wave
        case thinking
        case listening
        case encouraging
        case celebrating
        case neutral
    }

    let pose: Pose
    let size: CGFloat

    var body: some View {
        Image(systemName: mascotIcon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundStyle(Color.appPrimary)
    }

    private var mascotIcon: String {
        switch pose {
        case .wave: return "hand.wave.fill"
        case .thinking: return "brain.head.profile"
        case .listening: return "ear.fill"
        case .encouraging: return "hand.thumbsup.fill"
        case .celebrating: return "star.fill"
        case .neutral: return "face.smiling.fill"
        }
    }
}

#Preview {
    OnboardingContainer(user: .constant(nil)) {
        print("Onboarding complete")
    }
}
