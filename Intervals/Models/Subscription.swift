//
//  Subscription.swift
//  Intervals
//

import Foundation
import SwiftData

@Model
final class Subscription {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID

    // MARK: - Subscription Details
    var type: SubscriptionType
    var productId: String  // App Store product identifier
    var purchaseDate: Date
    var expirationDate: Date?
    var isActive: Bool

    // MARK: - Family Sharing
    var isFamilyPlan: Bool
    var familyMemberIds: [UUID]  // UserProfile IDs in this family

    // MARK: - Metadata
    var originalTransactionId: String?
    var lastVerifiedAt: Date?

    // MARK: - Initialization
    init(
        type: SubscriptionType,
        productId: String,
        expirationDate: Date? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.productId = productId
        self.purchaseDate = Date()
        self.expirationDate = expirationDate
        self.isActive = true
        self.isFamilyPlan = type == .family
        self.familyMemberIds = []
    }

    // MARK: - Computed Properties
    var isExpired: Bool {
        guard let expiration = expirationDate else { return false }
        return expiration < Date()
    }

    var daysRemaining: Int? {
        guard let expiration = expirationDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expiration).day
    }
}
