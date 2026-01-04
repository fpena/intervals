//
//  AgeSelectionView.swift
//  Intervals
//

import SwiftUI

struct AgeSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingScreenWrapper(viewModel: viewModel) {
            VStack(spacing: 20) {
                // Mascot
                OnboardingMascotView(pose: .neutral, size: 70)
                    .padding(.top, 16)

                // Headline
                Text(viewModel.headline(for: .ageSelection))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Age group grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(AgeGroup.allCases, id: \.self) { ageGroup in
                        AgeGroupCard(
                            ageGroup: ageGroup,
                            isSelected: viewModel.ageGroup == ageGroup
                        ) {
                            viewModel.ageGroup = ageGroup
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct AgeGroupCard: View {
    let ageGroup: AgeGroup
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: ageGroup.icon)
                    .font(.largeTitle)
                    .foregroundStyle(isSelected ? Color.appPrimary : .secondary)

                Text(ageGroup.displayLabel)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
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
    AgeSelectionView(viewModel: OnboardingViewModel())
}
