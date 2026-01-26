//
//  Shadows.swift
//  Intervals
//

import SwiftUI

/// Shadow style configuration.
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

/// Predefined shadow presets for consistent elevation.
enum Shadow {
    /// Subtle shadow for cards and containers
    static let card = ShadowStyle(
        color: .black.opacity(0.1),
        radius: 8,
        x: 0,
        y: 2
    )

    /// More prominent shadow for elevated elements
    static let elevated = ShadowStyle(
        color: .black.opacity(0.15),
        radius: 12,
        x: 0,
        y: 4
    )

    /// Colored glow shadow - pass your brand color
    static func colored(_ color: Color, opacity: Double = 0.3) -> ShadowStyle {
        ShadowStyle(
            color: color.opacity(opacity),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

// MARK: - View Extension

extension View {
    /// Apply a shadow style to the view.
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}
