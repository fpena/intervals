//
//  SettingsView.swift
//  Intervals
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Profile header (not in a section)
                ProfileHeaderView(user: user)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                // Settings sections
                PracticeSettingsSection(user: user)
                SoundSettingsSection(user: user)
                NotificationsSection(user: user)
                SubscriptionSection()
                AboutSection()
                ParentControlsButton()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let user = UserProfile(name: "Luna", avatarId: "cat", currentGrade: .grade3)
    user.totalXP = 1250
    container.mainContext.insert(user)

    return SettingsView(user: user)
        .modelContainer(container)
}
