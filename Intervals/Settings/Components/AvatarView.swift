//
//  AvatarView.swift
//  Intervals
//

import SwiftUI

struct AvatarView: View {
    let avatarId: String
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary.opacity(0.3), Color.appSecondary.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: avatarIcon)
                .font(.system(size: size * 0.5))
                .foregroundStyle(Color.appPrimary)
        }
        .frame(width: size, height: size)
    }

    private var avatarIcon: String {
        // Map avatar IDs to SF Symbols
        switch avatarId {
        case "cat": return "cat.fill"
        case "dog": return "dog.fill"
        case "bird": return "bird.fill"
        case "star": return "star.fill"
        case "heart": return "heart.fill"
        case "music": return "music.note"
        case "piano": return "pianokeys"
        case "guitar": return "guitars.fill"
        default: return "person.crop.circle.fill"
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        AvatarView(avatarId: "default", size: 60)
        AvatarView(avatarId: "cat", size: 80)
        AvatarView(avatarId: "music", size: 100)
    }
}
