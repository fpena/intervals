import { query } from "./_generated/server";
import { v } from "convex/values";

// List all chapters for a specific composer (track)
export const listByComposer = query({
  args: { composerId: v.id("composers") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("chapters")
      .withIndex("by_track", (q) => q.eq("trackId", args.composerId))
      .filter((q) => q.eq(q.field("isActive"), true))
      .collect();
  },
});

// Get a single chapter by ID
export const get = query({
  args: { id: v.id("chapters") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

// List all active chapters
export const listAll = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db
      .query("chapters")
      .withIndex("by_active", (q) => q.eq("isActive", true))
      .collect();
  },
});
