import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // User profiles (for family subscription support)
  profiles: defineTable({
    deviceId: v.string(), // Device that created this profile
    name: v.string(),
    avatarId: v.string(),
    createdAt: v.float64(),
    updatedAt: v.float64(),
  })
    .index("by_device", ["deviceId"]),

  // User progress tracking (per profile)
  userProgress: defineTable({
    profileId: v.id("profiles"), // Links to profile
    exerciseId: v.id("exercises"),
    chapterId: v.id("chapters"),
    bestScore: v.float64(),
    bestStreak: v.float64(),
    totalXpEarned: v.float64(),
    completionCount: v.float64(),
    attemptCount: v.float64(),
    firstCompletedAt: v.float64(),
    lastCompletedAt: v.float64(),
    lastAttemptedAt: v.float64(),
  })
    .index("by_profile", ["profileId"])
    .index("by_profile_exercise", ["profileId", "exerciseId"])
    .index("by_profile_chapter", ["profileId", "chapterId"]),

  // Aggregated user stats (per profile)
  userStats: defineTable({
    profileId: v.id("profiles"),
    totalXp: v.float64(),
    currentStreak: v.float64(),
    longestStreak: v.float64(),
    lastActivityAt: v.float64(),
    exercisesCompleted: v.float64(),
    createdAt: v.float64(),
    updatedAt: v.float64(),
  })
    .index("by_profile", ["profileId"]),

  chapters: defineTable({
    description: v.string(),
    isActive: v.boolean(),
    isBossChapter: v.boolean(),
    name: v.string(),
    sortOrder: v.float64(),
    trackId: v.id("composers"),
    unlockXpThreshold: v.float64(),
  })
    .index("by_track", ["trackId", "sortOrder"])
    .index("by_active", ["isActive", "sortOrder"]),
  composers: defineTable({
    accessTier: v.string(),
    birthYear: v.float64(),
    childFriendlyName: v.string(),
    deathYear: v.float64(),
    era: v.string(),
    freePreviewExercises: v.float64(),
    illustrationStorageId: v.string(),
    isActive: v.boolean(),
    name: v.string(),
    shortBio: v.string(),
    slug: v.string(),
    sortOrder: v.float64(),
    themePrimaryColor: v.string(),
    themeSecondaryColor: v.string(),
  })
    .index("by_slug", ["slug"])
    .index("by_era", ["era"])
    .index("by_sort_order", ["sortOrder"])
    .index("by_active", ["isActive", "sortOrder"]),
  exercises: defineTable({
    chapterId: v.id("chapters"),
    config: v.string(),
    difficulty: v.float64(),
    exerciseTypeSlug: v.string(),
    instructions: v.string(),
    isActive: v.boolean(),
    name: v.string(),
    passingScorePercent: v.float64(),
    sortOrder: v.float64(),
    xpReward: v.float64(),
  })
    .index("by_chapter", ["chapterId", "sortOrder"])
    .index("by_active", ["isActive", "sortOrder"]),
});
