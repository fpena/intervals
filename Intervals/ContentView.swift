//
//  ContentView.swift
//  Intervals
//
//  Created by Felipe Pena on 2025-12-13.
//

import SwiftUI

struct ContentView: View {
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
                    ExerciseView()
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
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
