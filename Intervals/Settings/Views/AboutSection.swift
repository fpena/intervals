//
//  AboutSection.swift
//  Intervals
//

import SwiftUI
import StoreKit

struct AboutSection: View {
    @Environment(\.openURL) var openURL

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        Section("About") {
            // Help & Support
            Button {
                openURL(URL(string: "https://intervals.app/support")!)
            } label: {
                HStack {
                    SettingsRow(
                        icon: "questionmark.circle.fill",
                        iconColor: .purple,
                        title: "Help & Support"
                    )
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)

            // Send Feedback
            Button {
                openURL(URL(string: "mailto:support@intervals.app?subject=Feedback%20-%20Intervals%20v\(appVersion)")!)
            } label: {
                HStack {
                    SettingsRow(
                        icon: "envelope.fill",
                        iconColor: .blue,
                        title: "Send Feedback"
                    )
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)

            // Rate the App
            Button {
                requestAppReview()
            } label: {
                SettingsRow(
                    icon: "star.fill",
                    iconColor: .yellow,
                    title: "Rate the App"
                )
            }
            .foregroundStyle(.primary)

            // Privacy Policy
            Button {
                openURL(URL(string: "https://intervals.app/privacy")!)
            } label: {
                HStack {
                    SettingsRow(
                        icon: "doc.text.fill",
                        iconColor: .gray,
                        title: "Privacy Policy"
                    )
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)

            // Terms of Service
            Button {
                openURL(URL(string: "https://intervals.app/terms")!)
            } label: {
                HStack {
                    SettingsRow(
                        icon: "doc.text.fill",
                        iconColor: .gray,
                        title: "Terms of Service"
                    )
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)

            // Version info (non-tappable)
            HStack {
                SettingsRow(
                    icon: "info.circle.fill",
                    iconColor: .gray,
                    title: "Version"
                )
                Spacer()
                Text("\(appVersion) (\(buildNumber))")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func requestAppReview() {
        #if os(iOS)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        #endif
    }
}

#Preview {
    List {
        AboutSection()
    }
}
