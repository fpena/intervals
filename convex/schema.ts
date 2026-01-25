import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
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
});
