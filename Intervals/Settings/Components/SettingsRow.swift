//
//  SettingsRow.swift
//  Intervals
//

import SwiftUI

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var value: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Icon with colored background
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .cornerRadius(6)

            // Title
            Text(title)

            // Optional value
            if let value {
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    List {
        SettingsRow(icon: "target", iconColor: .orange, title: "Daily Goal", value: "10 min")
        SettingsRow(icon: "book.fill", iconColor: .blue, title: "Current Grade", value: "Grade 3")
        SettingsRow(icon: "bell.fill", iconColor: .red, title: "Notifications")
    }
}
