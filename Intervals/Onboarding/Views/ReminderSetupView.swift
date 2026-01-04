//
//  ReminderSetupView.swift
//  Intervals
//

import SwiftUI

struct ReminderSetupView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingScreenWrapper(viewModel: viewModel) {
            VStack(spacing: 20) {
                // Mascot
                ZStack {
                    OnboardingMascotView(pose: .neutral, size: 70)

                    Image(systemName: "bell.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appPrimary)
                        .offset(x: 35, y: -25)
                }
                .padding(.top, 16)

                // Headline
                Text(viewModel.headline(for: .reminderSetup))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Subtext
                Text(viewModel.subtext(for: .reminderSetup))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Enable toggle
                Toggle(isOn: $viewModel.reminderEnabled) {
                    Label("Daily Reminders", systemImage: "bell.badge.fill")
                }
                .toggleStyle(.switch)
                .tint(Color.appPrimary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal, 24)

                if viewModel.reminderEnabled {
                    VStack(spacing: 12) {
                        // Time picker
                        HStack {
                            Text("Time")
                                .font(.headline)

                            Spacer()

                            DatePicker(
                                "",
                                selection: $viewModel.reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )

                        // Days selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Days")
                                .font(.headline)

                            HStack(spacing: 6) {
                                ForEach(Weekday.allCases, id: \.self) { day in
                                    DayToggleButton(
                                        day: day,
                                        isSelected: viewModel.reminderDays.contains(day)
                                    ) {
                                        if viewModel.reminderDays.contains(day) {
                                            viewModel.reminderDays.remove(day)
                                        } else {
                                            viewModel.reminderDays.insert(day)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.reminderEnabled)
        }
    }
}

struct DayToggleButton: View {
    let day: Weekday
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(day.initial)
                .font(.caption.bold())
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? Color.appPrimary : Color(.tertiarySystemBackground))
                )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    ReminderSetupView(viewModel: OnboardingViewModel())
}
