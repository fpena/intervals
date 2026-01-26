//
//  ComposerService.swift
//  Intervals
//
//  Created by Felipe Pena on 2026-01-25.
//

import Foundation
import Combine

/// Service for fetching composer data from Convex
@MainActor
class ComposerService: ObservableObject {
    static let shared = ComposerService()

    private let client: ConvexClient

    @Published var composers: [Composer] = []
    @Published var isLoading = false
    @Published var error: Error?

    init(client: ConvexClient = .shared) {
        self.client = client
    }

    /// Fetch all active composers
    func fetchComposers() async {
        isLoading = true
        error = nil

        do {
            let fetchedComposers: [Composer] = try await client.query("composers:list")
            self.composers = fetchedComposers.sorted { $0.sortOrder < $1.sortOrder }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Fetch a specific composer by slug
    func fetchComposer(bySlug slug: String) async -> Composer? {
        do {
            let composer: Composer? = try await client.query(
                "composers:getBySlug",
                args: ["slug": slug]
            )
            return composer
        } catch {
            self.error = error
            return nil
        }
    }

    /// Fetch composers by era
    func fetchComposers(byEra era: String) async -> [Composer] {
        do {
            let composers: [Composer] = try await client.query(
                "composers:getByEra",
                args: ["era": era]
            )
            return composers.sorted { $0.sortOrder < $1.sortOrder }
        } catch {
            self.error = error
            return []
        }
    }

    // MARK: - Chapter Methods

    /// Fetch chapters for a specific composer
    func fetchChapters(forComposerId composerId: String) async -> [Chapter] {
        do {
            let chapters: [Chapter] = try await client.query(
                "chapters:listByComposer",
                args: ["composerId": composerId]
            )
            return chapters.sorted { $0.sortOrder < $1.sortOrder }
        } catch {
            self.error = error
            return []
        }
    }

    /// Fetch a single chapter by ID
    func fetchChapter(byId id: String) async -> Chapter? {
        do {
            let chapter: Chapter? = try await client.query(
                "chapters:get",
                args: ["id": id]
            )
            return chapter
        } catch {
            self.error = error
            return nil
        }
    }

    // MARK: - Exercise Methods

    /// Fetch exercises for a specific chapter
    func fetchExercises(forChapterId chapterId: String) async -> [Exercise] {
        do {
            let exercises: [Exercise] = try await client.query(
                "exercises:listByChapter",
                args: ["chapterId": chapterId]
            )
            return exercises.sorted { $0.sortOrder < $1.sortOrder }
        } catch {
            self.error = error
            return []
        }
    }

    func clearError() {
        error = nil
    }
}
