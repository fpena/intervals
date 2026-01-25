//
//  ComposerListView.swift
//  Intervals
//
//  Created by Felipe Pena on 2026-01-25.
//

import SwiftUI

struct ComposerListView: View {
    @StateObject private var composerService = ComposerService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                if composerService.isLoading {
                    loadingView
                } else if composerService.composers.isEmpty {
                    emptyStateView
                } else {
                    composerGrid
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Choose a Garden")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await composerService.fetchComposers()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Explore Musical Gardens")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Each composer has their own garden filled with musical games and challenges")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading gardens...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No gardens available")
                .font(.headline)

            Text("Check back later for new musical adventures")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if composerService.error != nil {
                Button("Try Again") {
                    Task {
                        await composerService.fetchComposers()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 60)
    }

    // MARK: - Composer Grid

    private var composerGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(composerService.composers) { composer in
                NavigationLink {
                    ComposerGardenView(composer: composer)
                } label: {
                    ComposerCardView(composer: composer)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Composer Card View

struct ComposerCardView: View {
    let composer: Composer

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image from illustrationStorageId
            AsyncImage(url: URL(string: composer.illustrationStorageId)) { phase in
                switch phase {
                case .empty:
                    // Loading placeholder with gradient
                    LinearGradient(
                        colors: [composer.primaryColor, composer.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    // Fallback gradient on error
                    LinearGradient(
                        colors: [composer.primaryColor, composer.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                @unknown default:
                    LinearGradient(
                        colors: [composer.primaryColor, composer.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Dark tint overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Content overlay
            VStack(spacing: 8) {
                Spacer()

                Text(composer.childFriendlyName)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(composer.era)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Text(composer.lifespan)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))

                // Access tier badge - always reserve space for consistent height
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                    Text("Premium")
                        .font(.caption2)
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.15))
                .clipShape(Capsule())
                .opacity(composer.isFree ? 0 : 1)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ComposerListView()
    }
}
