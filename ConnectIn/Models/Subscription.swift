//
//  Subscription.swift
//  ConnectIn
//

import Foundation

/// ConnectIn Pro membership state. Single tier, $4.99/month, 7-day free trial.
/// Persisted on `AppState` so the demo can move between trial / active / expired
/// without backend wiring.
enum SubscriptionStatus: String, Codable, Hashable {
    case none       // Never started a trial or subscribed
    case trialing   // Currently inside the 7-day free trial
    case active     // Paying member
    case expired    // Cancelled or lapsed past renewal
}

struct Subscription: Codable, Hashable {
    /// Current state of the user's membership.
    var status: SubscriptionStatus
    /// When the trial or subscription kicked off.
    var startedAt: Date?
    /// Next billing or trial-end date.
    var renewsAt: Date?

    /// Sticker price — kept on the model so the UI never hard-codes it.
    static let monthlyPrice: Double = 4.99
    static let trialDays: Int = 7
    static let planName: String = "ConnectIn Pro"

    static let inactive = Subscription(
        status: .none,
        startedAt: nil,
        renewsAt: nil
    )

    /// `true` while the membership unlocks Pro features (trial OR active).
    var hasAccess: Bool {
        status == .trialing || status == .active
    }

    /// Days remaining until trial-end or renewal. Negative numbers clamp to 0.
    var daysUntilRenewal: Int? {
        guard let renews = renewsAt else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: renews).day ?? 0
        return max(0, days)
    }

    /// Headline label for status pills + cards.
    var displayLabel: String {
        switch status {
        case .none: return "Not subscribed"
        case .trialing: return "Free trial"
        case .active: return "Pro Member"
        case .expired: return "Membership expired"
        }
    }
}
