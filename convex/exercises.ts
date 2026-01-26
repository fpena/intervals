import { query } from "./_generated/server";
import { v } from "convex/values";

// List all exercises for a specific chapter
export const listByChapter = query({
  args: { chapterId: v.id("chapters") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("exercises")
      .withIndex("by_chapter", (q) => q.eq("chapterId", args.chapterId))
      .filter((q) => q.eq(q.field("isActive"), true))
      .collect();
  },
});

// Get a single exercise by ID
export const get = query({
  args: { id: v.id("exercises") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

// List all active exercises
export const listAll = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db
      .query("exercises")
      .withIndex("by_active", (q) => q.eq("isActive", true))
      .collect();
  },
});
