//
//  SubscriptionSection.swift
//  Intervals
//

import SwiftUI

struct SubscriptionSection: View {
    @State private var showPaywall = false
    @State private var isRestoring = false
    @State private var currentPlan: SubscriptionType = .free

    var body: some View {
        Section("Subscription") {
            // Current plan
            HStack {
                SettingsRow(
                    icon: "star.fill",
                    iconColor: .yellow,
                    title: "Plan",
                    value: currentPlan.displayName
                )
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Upgrade button (if free)
            if currentPlan == .free {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Text("Upgrade to Premium")
                            .foregroundStyle(Color.appPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Restore purchases
            Button {
                restorePurchases()
            } label: {
                HStack {
                    SettingsRow(
                        icon: "arrow.clockwise",
                        iconColor: .blue,
                        title: "Restore Purchases"
                    )
                    Spacer()
                    if isRestoring {
                        ProgressView()
                    }
                }
            }
            .disabled(isRestoring)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private func restorePurchases() {
        isRestoring = true
        // TODO: Implement StoreKit restore
        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                isRestoring = false
            }
        }
    }
}

// MARK: - Subscription Type Display Name

extension SubscriptionType {
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .individual: return "Individual"
        case .family: return "Family"
        }
    }
}

// MARK: - Placeholder Paywall View

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)

                Text("Unlock Premium")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Get access to all grades, instruments, and features.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        // TODO: Purchase individual
                    } label: {
                        Text("Individual - $79.99/year")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.appPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        // TODO: Purchase family
                    } label: {
                        Text("Family - $119.99/year")
                            .font(.headline)
                            .foregroundColor(.appPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.appPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        SubscriptionSection()
    }
}
