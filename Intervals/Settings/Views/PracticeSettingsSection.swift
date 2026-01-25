//
//  PracticeSettingsSection.swift
//  Intervals
//

import SwiftUI
import SwiftData

struct PracticeSettingsSection: View {
    @Bindable var user: UserProfile

    var body: some View {
        Section("Practice") {
            // Daily Goal
            NavigationLink {
                DailyGoalPicker(selectedMinutes: $user.dailyGoalMinutes)
            } label: {
                SettingsRow(
                    icon: "target",
                    iconColor: .orange,
                    title: "Daily Goal",
                    value: "\(user.dailyGoalMinutes) min"
                )
            }

            // Current Grade
            NavigationLink {
                GradePicker(selectedGrade: $user.currentGrade)
            } label: {
                SettingsRow(
                    icon: "book.fill",
                    iconColor: .blue,
                    title: "Current Grade",
                    value: user.currentGrade.displayName
                )
            }

            // Instrument
            NavigationLink {
                InstrumentPicker(selectedInstrument: $user.preferredInstrument)
            } label: {
                SettingsRow(
                    icon: "pianokeys",
                    iconColor: .purple,
                    title: "Instrument",
                    value: user.preferredInstrument.displayName
                )
            }
        }
    }
}

// MARK: - Daily Goal Picker

struct DailyGoalPicker: View {
    @Binding var selectedMinutes: Int
    @Environment(\.dismiss) var dismiss

    private let options = [5, 10, 15, 20, 30]

    var body: some View {
        List {
            ForEach(options, id: \.self) { minutes in
                Button {
                    selectedMinutes = minutes
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(minutes) minutes")
                                .font(.body)
                            Text(descriptionFor(minutes))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if selectedMinutes == minutes {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
        .navigationTitle("Daily Goal")
    }

    private func descriptionFor(_ minutes: Int) -> String {
        switch minutes {
        case 5: return "Quick practice"
        case 10: return "Recommended"
        case 15: return "Building habits"
        case 20: return "Serious learner"
        case 30: return "Exam preparation"
        default: return ""
        }
    }
}

// MARK: - Grade Picker

struct GradePicker: View {
    @Binding var selectedGrade: Grade
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            ForEach(Grade.allCases, id: \.self) { grade in
                Button {
                    selectedGrade = grade
                    dismiss()
                } label: {
                    HStack {
                        Text(grade.displayName)
                        Spacer()
                        if selectedGrade == grade {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
        .navigationTitle("Current Grade")
    }
}

// MARK: - Instrument Picker

struct InstrumentPicker: View {
    @Binding var selectedInstrument: InstrumentType
    @Environment(\.dismiss) var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(InstrumentType.allCases, id: \.self) { instrument in
                    InstrumentCard(
                        instrument: instrument,
                        isSelected: selectedInstrument == instrument,
                        onTap: {
                            selectedInstrument = instrument
                            AudioManager.shared.selectedInstrument = instrument
                        }
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Instrument Sound")
    }
}

struct InstrumentCard: View {
    let instrument: InstrumentType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: iconFor(instrument))
                    .font(.system(size: 32))
                    .foregroundStyle(isSelected ? Color.appPrimary : Color.primary)

                Text(instrument.displayName)
                    .font(.caption)
                    .foregroundStyle(isSelected ? Color.appPrimary : Color.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.appPrimary.opacity(0.1) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appPrimary : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func iconFor(_ instrument: InstrumentType) -> String {
        switch instrument {
        case .piano: return "pianokeys"
        case .guitar: return "guitars.fill"
        case .violin: return "music.note"
        case .flute: return "wind"
        case .clarinet: return "music.quarternote.3"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let user = UserProfile(name: "Luna", currentGrade: .grade3)
    container.mainContext.insert(user)

    return NavigationStack {
        List {
            PracticeSettingsSection(user: user)
        }
    }
    .modelContainer(container)
}
