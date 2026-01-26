//
//  ComposerGardenView.swift
//  Intervals
//
//  Created by Felipe Pena on 2026-01-25.
//

import SwiftUI

/// The garden view for a specific composer - contains chapters
struct ComposerGardenView: View {
    let composer: Composer

    @StateObject private var composerService = ComposerService.shared
    @StateObject private var progressService = UserProgressService.shared
    @State private var chapters: [Chapter] = []
    @State private var isLoadingChapters = true
    @State private var selectedChapter: Chapter?

    /// User's total XP from Convex
    private var userXp: Double {
        Double(progressService.totalXP)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Composer Header
                composerHeader

                // Chapters Section
                chaptersSection
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
        .task {
            await loadChapters()
        }
        .navigationDestination(item: $selectedChapter) { chapter in
            ChapterExercisesView(chapter: chapter, themeColor: composer.primaryColor)
        }
    }

    private func loadChapters() async {
        isLoadingChapters = true
        chapters = await composerService.fetchChapters(forComposerId: composer.id)
        isLoadingChapters = false
    }

    // MARK: - Composer Header

    private var composerHeader: some View {
        VStack(spacing: Spacing.md) {
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

            VStack(spacing: Spacing.xxs) {
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
                    .padding(.top, Spacing.xxs)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    // MARK: - Chapters Section

    private var chaptersSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Chapters")
                .font(.headline)
                .padding(.horizontal)

            if isLoadingChapters {
                ChapterGridSkeleton()
            } else if chapters.isEmpty {
                emptyChaptersView
            } else {
                chapterGrid
            }
        }
    }

    private var emptyChaptersView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No chapters available yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    private var chapterGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md)
            ],
            spacing: Spacing.md
        ) {
            ForEach(chapters) { chapter in
                ChapterCard(
                    chapter: chapter,
                    color: composer.primaryColor,
                    isUnlocked: chapter.isUnlocked(userXp: userXp)
                ) {
                    selectedChapter = chapter
                }
            }
        }
    }
}

// MARK: - Chapter Card

struct ChapterCard: View {
    let chapter: Chapter
    let color: Color
    let isUnlocked: Bool
    let action: () -> Void

    private var icon: String {
        if chapter.isBossChapter {
            return "star.fill"
        }
        return isUnlocked ? "book.fill" : "lock.fill"
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(color.opacity(isUnlocked ? 1.0 : 0.3))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(isUnlocked ? .white : .secondary)
                }

                Text(chapter.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                // Always reserve space for caption to maintain equal height
                Group {
                    if chapter.isBossChapter {
                        Text("Boss Chapter")
                            .foregroundColor(.appAccent)
                    } else if !isUnlocked {
                        Text("\(Int(chapter.unlockXpThreshold)) XP")
                            .foregroundColor(.secondary)
                    } else {
                        Text(" ")
                            .foregroundColor(.clear)
                    }
                }
                .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .shadow(Shadow.card)
            .opacity(isUnlocked ? 1.0 : 0.7)
        }
        .disabled(!isUnlocked)
    }
}

// MARK: - Chapter Grid Skeleton

struct ChapterGridSkeleton: View {
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md)
            ],
            spacing: Spacing.md
        ) {
            ForEach(0..<4, id: \.self) { _ in
                ChapterCardSkeleton()
            }
        }
    }
}

struct ChapterCardSkeleton: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            SkeletonShape(width: 60, height: 60, cornerRadius: CGFloat(CornerRadius.md))

            SkeletonShape(width: 80, height: 14)

            SkeletonShape(width: 50, height: 10)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
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
