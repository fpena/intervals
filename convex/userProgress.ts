import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// ============================================================================
// PROFILE MANAGEMENT
// ============================================================================

// Get all profiles for a device
export const getProfiles = query({
  args: { deviceId: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("profiles")
      .withIndex("by_device", (q) => q.eq("deviceId", args.deviceId))
      .collect();
  },
});

// Get a single profile by ID
export const getProfile = query({
  args: { profileId: v.id("profiles") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.profileId);
  },
});

// Create a new profile
export const createProfile = mutation({
  args: {
    deviceId: v.string(),
    name: v.string(),
    avatarId: v.string(),
  },
  handler: async (ctx, args) => {
    const now = Date.now();

    const profileId = await ctx.db.insert("profiles", {
      deviceId: args.deviceId,
      name: args.name,
      avatarId: args.avatarId,
      createdAt: now,
      updatedAt: now,
    });

    // Initialize user stats for this profile
    await ctx.db.insert("userStats", {
      profileId,
      totalXp: 0,
      currentStreak: 0,
      longestStreak: 0,
      lastActivityAt: now,
      exercisesCompleted: 0,
      createdAt: now,
      updatedAt: now,
    });

    return await ctx.db.get(profileId);
  },
});

// Update profile
export const updateProfile = mutation({
  args: {
    profileId: v.id("profiles"),
    name: v.optional(v.string()),
    avatarId: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const updates: any = { updatedAt: Date.now() };
    if (args.name !== undefined) updates.name = args.name;
    if (args.avatarId !== undefined) updates.avatarId = args.avatarId;

    await ctx.db.patch(args.profileId, updates);
    return await ctx.db.get(args.profileId);
  },
});

// Delete profile and all associated data
export const deleteProfile = mutation({
  args: { profileId: v.id("profiles") },
  handler: async (ctx, args) => {
    // Delete all progress records
    const progress = await ctx.db
      .query("userProgress")
      .withIndex("by_profile", (q) => q.eq("profileId", args.profileId))
      .collect();

    for (const p of progress) {
      await ctx.db.delete(p._id);
    }

    // Delete user stats
    const stats = await ctx.db
      .query("userStats")
      .withIndex("by_profile", (q) => q.eq("profileId", args.profileId))
      .first();

    if (stats) {
      await ctx.db.delete(stats._id);
    }

    // Delete profile
    await ctx.db.delete(args.profileId);

    return { success: true };
  },
});

// ============================================================================
// USER STATS QUERIES
// ============================================================================

// Get user stats for a profile
export const getUserStats = query({
  args: { profileId: v.id("profiles") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("userStats")
      .withIndex("by_profile", (q) => q.eq("profileId", args.profileId))
      .first();
  },
});

// ============================================================================
// PROGRESS QUERIES
// ============================================================================

// Get progress for a specific exercise
export const getExerciseProgress = query({
  args: {
    profileId: v.id("profiles"),
    exerciseId: v.id("exercises"),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("userProgress")
      .withIndex("by_profile_exercise", (q) =>
        q.eq("profileId", args.profileId).eq("exerciseId", args.exerciseId)
      )
      .first();
  },
});

// Get all progress for a chapter
export const getChapterProgress = query({
  args: {
    profileId: v.id("profiles"),
    chapterId: v.id("chapters"),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("userProgress")
      .withIndex("by_profile_chapter", (q) =>
        q.eq("profileId", args.profileId).eq("chapterId", args.chapterId)
      )
      .collect();
  },
});

// Get all progress for a profile
export const getAllProgress = query({
  args: { profileId: v.id("profiles") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("userProgress")
      .withIndex("by_profile", (q) => q.eq("profileId", args.profileId))
      .collect();
  },
});

// ============================================================================
// RECORD COMPLETION
// ============================================================================

export const recordCompletion = mutation({
  args: {
    deviceId: v.string(),
    name: v.optional(v.string()),
    avatarId: v.optional(v.string()),
    exerciseId: v.id("exercises"),
    chapterId: v.id("chapters"),
    score: v.float64(),
    streak: v.float64(),
    xpEarned: v.float64(),
    passed: v.boolean(),
  },
  handler: async (ctx, args) => {
    const now = Date.now();

    // Find or create profile for this device
    let profile = await ctx.db
      .query("profiles")
      .withIndex("by_device", (q) => q.eq("deviceId", args.deviceId))
      .first();

    if (!profile) {
      // Auto-create profile
      const profileId = await ctx.db.insert("profiles", {
        deviceId: args.deviceId,
        name: args.name ?? "Player",
        avatarId: args.avatarId ?? "default",
        createdAt: now,
        updatedAt: now,
      });

      // Initialize user stats for this profile
      await ctx.db.insert("userStats", {
        profileId,
        totalXp: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActivityAt: now,
        exercisesCompleted: 0,
        createdAt: now,
        updatedAt: now,
      });

      profile = await ctx.db.get(profileId);
    }

    const profileId = profile!._id;

    // Find existing progress for this exercise
    const existing = await ctx.db
      .query("userProgress")
      .withIndex("by_profile_exercise", (q) =>
        q.eq("profileId", profileId).eq("exerciseId", args.exerciseId)
      )
      .first();

    if (existing) {
      // Update existing progress
      const updates: any = {
        attemptCount: existing.attemptCount + 1,
        lastAttemptedAt: now,
      };

      if (args.passed) {
        updates.completionCount = existing.completionCount + 1;
        updates.lastCompletedAt = now;
        updates.totalXpEarned = existing.totalXpEarned + args.xpEarned;

        if (args.score > existing.bestScore) {
          updates.bestScore = args.score;
        }
        if (args.streak > existing.bestStreak) {
          updates.bestStreak = args.streak;
        }
      }

      await ctx.db.patch(existing._id, updates);
    } else if (args.passed) {
      // Create new progress record (only if passed)
      await ctx.db.insert("userProgress", {
        profileId,
        exerciseId: args.exerciseId,
        chapterId: args.chapterId,
        bestScore: args.score,
        bestStreak: args.streak,
        totalXpEarned: args.xpEarned,
        completionCount: 1,
        attemptCount: 1,
        firstCompletedAt: now,
        lastCompletedAt: now,
        lastAttemptedAt: now,
      });
    }

    // Update user stats if passed
    if (args.passed) {
      await updateUserStats(ctx, profileId, args.xpEarned);
    }

    return { success: true, profile };
  },
});

// Helper to update user stats
async function updateUserStats(
  ctx: any,
  profileId: any,
  xpEarned: number
) {
  const now = Date.now();
  const today = new Date().setHours(0, 0, 0, 0);

  const existing = await ctx.db
    .query("userStats")
    .withIndex("by_profile", (q: any) => q.eq("profileId", profileId))
    .first();

  if (existing) {
    const lastActivityDay = new Date(existing.lastActivityAt).setHours(0, 0, 0, 0);
    const yesterday = today - 86400000;

    let newStreak = existing.currentStreak;

    if (lastActivityDay === today) {
      // Already practiced today
    } else if (lastActivityDay === yesterday) {
      // Practiced yesterday, increment streak
      newStreak += 1;
    } else {
      // Streak broken
      newStreak = 1;
    }

    await ctx.db.patch(existing._id, {
      totalXp: existing.totalXp + xpEarned,
      currentStreak: newStreak,
      longestStreak: Math.max(existing.longestStreak, newStreak),
      lastActivityAt: now,
      exercisesCompleted: existing.exercisesCompleted + 1,
      updatedAt: now,
    });
  } else {
    // Create new user stats (shouldn't happen if profile was created properly)
    await ctx.db.insert("userStats", {
      profileId,
      totalXp: xpEarned,
      currentStreak: 1,
      longestStreak: 1,
      lastActivityAt: now,
      exercisesCompleted: 1,
      createdAt: now,
      updatedAt: now,
    });
  }
}
