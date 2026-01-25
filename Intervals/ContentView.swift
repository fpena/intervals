//
//  ContentView.swift
//  Intervals
//
//  Created by Felipe Pena on 2025-12-13.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]
    @State private var showSettings = false

    private var currentUser: UserProfile {
        if let user = users.first {
            return user
        } else {
            let newUser = UserProfile(name: "Player")
            modelContext.insert(newUser)
            return newUser
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Branding
                VStack(spacing: 16) {
                    Image(systemName: "ear.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.appPrimary)

                    Text("Intervals")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Train your ear with musical intervals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Action
                NavigationLink {
                    ComposerListView()
                } label: {
                    Text("Start Practice")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 280, height: 56)
                        .background(
                            LinearGradient(
                                colors: [.appPrimary, .appSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding(.horizontal, 48)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(user: currentUser)
            }
            .onAppear {
                AudioManager.shared.syncInstrument(with: currentUser)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
