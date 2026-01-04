//
//  RootView.swift
//  Intervals
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]
    @State private var showOnboarding = false
    @State private var currentUser: UserProfile?

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingContainer(user: $currentUser) {
                    showOnboarding = false
                }
            } else {
                ContentView()
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
    }

    private func checkOnboardingStatus() {
        if let user = users.first {
            currentUser = user
            showOnboarding = !user.isSetupComplete
        } else {
            // No user exists, show onboarding
            showOnboarding = true
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
