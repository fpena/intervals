//
//  EditProfileView.swift
//  Intervals
//

import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var showDeleteConfirmation = false

    private let avatarOptions = [
        "default", "cat", "dog", "bird", "star", "heart", "music", "piano", "guitar"
    ]

    var body: some View {
        NavigationStack {
            Form {
                // Avatar Section
                Section {
                    VStack(spacing: 16) {
                        AvatarView(avatarId: user.avatarId, size: 100)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(avatarOptions, id: \.self) { avatarId in
                                AvatarView(avatarId: avatarId, size: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(user.avatarId == avatarId ? Color.appPrimary : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        user.avatarId = avatarId
                                    }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                // Name Section
                Section("Name") {
                    TextField("Name", text: $user.name)
                }

                // Date of Birth Section
                Section {
                    DatePicker(
                        "Date of Birth",
                        selection: Binding(
                            get: { user.dateOfBirth ?? Date() },
                            set: { user.dateOfBirth = $0 }
                        ),
                        in: ...Date(),
                        displayedComponents: .date
                    )

                    if user.dateOfBirth != nil {
                        Button("Remove Date of Birth", role: .destructive) {
                            user.dateOfBirth = nil
                        }
                    }
                } header: {
                    Text("Date of Birth")
                } footer: {
                    Text("Optional. Used to personalize content for your age.")
                }

                // Delete Profile Section
                Section {
                    Button("Delete Profile", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        user.updatedAt = Date()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Delete Profile?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(user)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete this profile and all progress. This cannot be undone.")
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let user = UserProfile(name: "Luna", avatarId: "cat", currentGrade: .grade3)
    container.mainContext.insert(user)

    return EditProfileView(user: user)
        .modelContainer(container)
}
