//
//  GoalSelectionView.swift
//  Intervals
//

import SwiftUI

struct GoalSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingScreenWrapper(viewModel: viewModel) {
            VStack(spacing: 20) {
                // Mascot
                OnboardingMascotView(pose: .encouraging, size: 70)
                    .padding(.top, 16)

                // Headline
                Text(viewModel.headline(for: .goalSelection))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Subtext
                Text(viewModel.subtext(for: .goalSelection))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Goal options
                VStack(spacing: 12) {
                    ForEach(LearningGoal.allCases, id: \.self) { goal in
                        GoalOptionCard(
                            goal: goal,
                            isSelected: viewModel.selectedGoal == goal
                        ) {
                            viewModel.selectedGoal = goal
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct GoalOptionCard: View {
    let goal: LearningGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.appPrimary : .secondary)
                    .frame(width: 32)

                Text(goal.displayLabel)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appPrimary)
                }
            }
            .padding()
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

#Preview {
    GoalSelectionView(viewModel: OnboardingViewModel())
}
