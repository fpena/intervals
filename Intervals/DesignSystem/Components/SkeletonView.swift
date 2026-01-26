//
//  SkeletonView.swift
//  Intervals
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Shimmer Modifier

/// A modifier that adds a shimmering animation effect for loading states.
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if !reduceMotion {
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.4),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
                    }
                }
            )
            .clipShape(Rectangle())
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Adds a shimmering animation for loading states.
    /// Respects `accessibilityReduceMotion` preference.
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Skeleton Shape

/// A reusable skeleton placeholder shape.
struct SkeletonShape: View {
    var width: CGFloat? = nil
    var height: CGFloat = 20
    var cornerRadius: CGFloat = 4

    private var skeletonColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray5)
        #else
        return Color.gray.opacity(0.2)
        #endif
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(skeletonColor)
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Composer Card Skeleton

/// Skeleton placeholder for a single composer card.
struct ComposerCardSkeleton: View {
    private var skeletonColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray5)
        #else
        return Color.gray.opacity(0.2)
        #endif
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(skeletonColor)

            // Content placeholder
            VStack(spacing: 8) {
                Spacer()

                // Title skeleton
                SkeletonShape(width: 100, height: 18, cornerRadius: 4)

                // Era skeleton
                SkeletonShape(width: 60, height: 12, cornerRadius: 4)

                // Lifespan skeleton
                SkeletonShape(width: 80, height: 10, cornerRadius: 4)

                // Badge skeleton
                SkeletonShape(width: 70, height: 20, cornerRadius: 6)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shimmer()
    }
}

// MARK: - Composer Grid Skeleton

/// Skeleton placeholder for the composer grid loading state.
struct ComposerGridSkeleton: View {
    let cardCount: Int

    init(cardCount: Int = 6) {
        self.cardCount = cardCount
    }

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(0..<cardCount, id: \.self) { _ in
                ComposerCardSkeleton()
            }
        }
    }
}

// MARK: - Previews

#Preview("Skeleton Shapes") {
    VStack(spacing: 16) {
        SkeletonShape(width: 200, height: 20)
        SkeletonShape(width: 150, height: 14)
        SkeletonShape(width: 100, height: 10)
    }
    .padding()
}

#Preview("Composer Card Skeleton") {
    ComposerCardSkeleton()
        .padding()
}

#Preview("Composer Grid Skeleton") {
    ScrollView {
        ComposerGridSkeleton()
            .padding()
    }
}
