//
//  ChapterExercisesView.swift
//  Intervals
//

import SwiftData
import SwiftUI

/// View that displays exercises for a specific chapter
struct ChapterExercisesView: View {
    let chapter: Chapter
    let themeColor: Color

    @StateObject private var composerService = ComposerService.shared
    @State private var exercises: [Exercise] = []
    @State private var isLoading = true
    @State private var selectedExercise: Exercise?
    @State private var completedExerciseIds: Set<String> = []
    @State private var exerciseStars: [String: Int] = [:]

    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]

    private var currentUser: UserProfile? {
        users.first
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                chapterHeader

                if isLoading {
                    ExerciseListSkeleton()
                } else if exercises.isEmpty {
                    emptyExercisesView
                } else {
                    exerciseList
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(chapter.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadExercises()
            loadProgress()
        }
        .navigationDestination(item: $selectedExercise) { exercise in
            exerciseView(for: exercise)
        }
    }

    @ViewBuilder
    private func exerciseView(for exercise: Exercise) -> some View {
        switch exercise.exerciseTypeSlug {
        case "pitch_direction":
            PitchDirectionExerciseView(
                exercise: exercise,
                themeColor: themeColor,
                onComplete: { result in
                    handleExerciseCompletion(result)
                }
            )
        default:
            // Fallback for unsupported exercise types
            Text("Exercise type '\(exercise.exerciseTypeSlug)' coming soon!")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }

    private func loadExercises() async {
        isLoading = true
        exercises = await composerService.fetchExercises(forChapterId: chapter.id)
        isLoading = false
    }

    private func loadProgress() {
        guard let user = currentUser else { return }

        completedExerciseIds = Set(
            user.completedExercises
                .filter { $0.chapterId == chapter.id && $0.completionCount > 0 }
                .map { $0.exerciseId }
        )

        exerciseStars = Dictionary(
            uniqueKeysWithValues: user.completedExercises
                .filter { $0.chapterId == chapter.id }
                .map { ($0.exerciseId, $0.starRating) }
        )
    }

    private func handleExerciseCompletion(_ result: ExerciseResult) {
        guard let user = currentUser else { return }

        let progressService = ExerciseProgressService(modelContext: modelContext)
        progressService.recordCompletion(
            user: user,
            exerciseId: result.exerciseId,
            chapterId: result.chapterId,
            score: result.score,
            streak: result.streak,
            xpEarned: result.xpEarned,
            passingScore: Int(exercises.first { $0.id == result.exerciseId }?.passingScorePercent ?? 60)
        )

        // Update local state
        if result.passed {
            completedExerciseIds.insert(result.exerciseId)
            let currentStars = exerciseStars[result.exerciseId] ?? 0
            let newStars = starRating(for: result.score)
            if newStars > currentStars {
                exerciseStars[result.exerciseId] = newStars
            }
        }
    }

    private func starRating(for score: Int) -> Int {
        switch score {
        case 90...100: return 3
        case 70..<90: return 2
        case 50..<70: return 1
        default: return 0
        }
    }

    private func progressStatus(for exercise: Exercise) -> ExerciseProgressStatus {
        if completedExerciseIds.contains(exercise.id) {
            return .completed(stars: exerciseStars[exercise.id] ?? 0)
        }
        return .notStarted
    }

    // MARK: - Chapter Header

    private var chapterHeader: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(themeColor)
                    .frame(width: 60, height: 60)

                Image(systemName: chapter.isBossChapter ? "star.fill" : "book.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Text(chapter.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if chapter.isBossChapter {
                Text("Boss Chapter")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.appAccent)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(Color.appAccent.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    // MARK: - Empty State

    private var emptyExercisesView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No exercises available yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        VStack(spacing: Spacing.md) {
            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                ExerciseRow(
                    exercise: exercise,
                    index: index + 1,
                    themeColor: themeColor,
                    progressStatus: progressStatus(for: exercise)
                ) {
                    selectedExercise = exercise
                }
            }
        }
    }
}

// MARK: - Exercise Row

struct ExerciseRow: View {
    let exercise: Exercise
    let index: Int
    let themeColor: Color
    let progressStatus: ExerciseProgressStatus
    let action: () -> Void

    private var isCompleted: Bool {
        if case .completed = progressStatus { return true }
        return false
    }

    private var starCount: Int {
        if case .completed(let stars) = progressStatus { return stars }
        return 0
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                // Index badge with completion indicator
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.appSuccess : themeColor)
                        .frame(width: 36, height: 36)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        Text("\(index)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }

                // Exercise info
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(exercise.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    HStack(spacing: Spacing.sm) {
                        Label(exercise.difficultyLabel, systemImage: "chart.bar.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Label("\(Int(exercise.xpReward)) XP", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.appAccent)
                    }
                }

                Spacer()

                // Stars for completed exercises
                if isCompleted && starCount > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < starCount ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(index < starCount ? .appAccent : .secondary.opacity(0.3))
                        }
                    }
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .shadow(Shadow.card)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Exercise List Skeleton

struct ExerciseListSkeleton: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            ForEach(0..<5, id: \.self) { _ in
                ExerciseRowSkeleton()
            }
        }
    }
}

struct ExerciseRowSkeleton: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            SkeletonShape(width: 36, height: 36, cornerRadius: 18)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                SkeletonShape(width: 150, height: 16)
                SkeletonShape(width: 100, height: 12)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChapterExercisesView(
            chapter: Chapter(
                _id: "preview",
                name: "Getting Started",
                description: "Learn the basics of intervals",
                isActive: true,
                isBossChapter: false,
                sortOrder: 1,
                trackId: "composer1",
                unlockXpThreshold: 0
            ),
            themeColor: .blue
        )
    }
}
