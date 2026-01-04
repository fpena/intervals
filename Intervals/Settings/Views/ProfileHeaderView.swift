//
//  ProfileHeaderView.swift
//  Intervals
//

import SwiftUI
import SwiftData

struct ProfileHeaderView: View {
    @Bindable var user: UserProfile
    @State private var showEditProfile = false

    var body: some View {
        VStack(spacing: 12) {
            // Avatar (tappable to change)
            AvatarView(avatarId: user.avatarId, size: 80)
                .onTapGesture { showEditProfile = true }

            // Name
            Text(user.name)
                .font(.title2)
                .fontWeight(.semibold)

            // Stats summary
            Text("\(user.currentGrade.displayName) \u{2022} \(user.totalXP.formatted()) XP")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Edit button
            Button("Edit Profile") {
                showEditProfile = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(user: user)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let user = UserProfile(name: "Luna", avatarId: "cat", currentGrade: .grade3)
    user.totalXP = 1250
    container.mainContext.insert(user)

    return ProfileHeaderView(user: user)
        .modelContainer(container)
}
