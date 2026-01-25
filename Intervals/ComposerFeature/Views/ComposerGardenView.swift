//
//  ComposerGardenView.swift
//  Intervals
//
//  Created by Felipe Pena on 2026-01-25.
//

import SwiftUI

/// The garden view for a specific composer - contains mini games
struct ComposerGardenView: View {
    let composer: Composer

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Composer Header
                composerHeader

                // Mini Games Section
                miniGamesSection
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    composer.primaryColor.opacity(0.1),
                    composer.secondaryColor.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("\(composer.childFriendlyName)'s Garden")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Composer Header

    private var composerHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [composer.primaryColor, composer.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Text(composer.childFriendlyName.prefix(1))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text(composer.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(composer.era)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(composer.shortBio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Mini Games Section

    private var miniGamesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Musical Games")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                MiniGameCard(
                    title: "Intervals",
                    icon: "music.note.list",
                    color: composer.primaryColor,
                    isLocked: false
                ) {
                    // Navigate to interval exercise
                }

                MiniGameCard(
                    title: "Chords",
                    icon: "pianokeys",
                    color: composer.secondaryColor,
                    isLocked: true
                ) {
                    // Navigate to chord exercise
                }

                MiniGameCard(
                    title: "Melody",
                    icon: "waveform",
                    color: composer.primaryColor.opacity(0.8),
                    isLocked: true
                ) {
                    // Navigate to melody exercise
                }

                MiniGameCard(
                    title: "Rhythm",
                    icon: "metronome",
                    color: composer.secondaryColor.opacity(0.8),
                    isLocked: true
                ) {
                    // Navigate to rhythm exercise
                }
            }
        }
    }
}

// MARK: - Mini Game Card

struct MiniGameCard: View {
    let title: String
    let icon: String
    let color: Color
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(isLocked ? 0.3 : 1.0))
                        .frame(width: 60, height: 60)

                    Image(systemName: isLocked ? "lock.fill" : icon)
                        .font(.title)
                        .foregroundColor(isLocked ? .secondary : .white)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isLocked ? .secondary : .primary)

                if isLocked {
                    Text("Coming Soon")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .opacity(isLocked ? 0.7 : 1.0)
        }
        .disabled(isLocked)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ComposerGardenView(composer: Composer(
            _id: "preview",
            accessTier: "free",
            birthYear: 1685,
            childFriendlyName: "Johann",
            deathYear: 1750,
            era: "Baroque",
            freePreviewExercises: 5,
            illustrationStorageId: "",
            isActive: true,
            name: "Johann Sebastian Bach",
            shortBio: "Master of counterpoint and fugue",
            slug: "bach",
            sortOrder: 1,
            themePrimaryColor: "#8B4513",
            themeSecondaryColor: "#D2691E"
        ))
    }
}
