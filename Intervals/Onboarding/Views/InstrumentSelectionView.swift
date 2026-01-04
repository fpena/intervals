//
//  InstrumentSelectionView.swift
//  Intervals
//

import SwiftUI

struct InstrumentSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showOtherInput = false

    var body: some View {
        OnboardingScreenWrapper(viewModel: viewModel) {
            VStack(spacing: 20) {
                // Mascot
                OnboardingMascotView(pose: .listening, size: 70)
                    .padding(.top, 16)

                // Headline
                Text(viewModel.headline(for: .instrumentSelection))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Subtext
                Text(viewModel.subtext(for: .instrumentSelection))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Instrument grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(OnboardingInstrument.allCases, id: \.self) { instrument in
                        OnboardingInstrumentCard(
                            instrument: instrument,
                            isSelected: viewModel.selectedInstruments.contains(instrument)
                        ) {
                            toggleInstrument(instrument)
                        }
                    }
                }

                // Other instrument text input
                if showOtherInput {
                    TextField("What instrument?", text: $viewModel.otherInstrumentText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }

                // Hint if nothing selected
                if viewModel.selectedInstruments.isEmpty {
                    Text("Select at least one instrument")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func toggleInstrument(_ instrument: OnboardingInstrument) {
        if viewModel.selectedInstruments.contains(instrument) {
            viewModel.selectedInstruments.remove(instrument)
            if instrument == .other {
                showOtherInput = false
            }
        } else {
            viewModel.selectedInstruments.insert(instrument)
            if instrument == .other {
                showOtherInput = true
            }
        }
    }
}

struct OnboardingInstrumentCard: View {
    let instrument: OnboardingInstrument
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: instrument.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.appPrimary : .secondary)

                Text(instrument.displayLabel)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appPrimary)
                        .padding(6)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    InstrumentSelectionView(viewModel: OnboardingViewModel())
}
