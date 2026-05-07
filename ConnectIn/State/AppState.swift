//
//  AppState.swift
//  ConnectIn
//

import Combine
import Foundation
import SwiftUI

/// Top-level tabs surfaced in `ContentView`.
enum MainTab: Hashable {
    case dashboard
    case browse
    case sessions
    case profile
}

/// Global auth + onboarding state for the app, persisted to `UserDefaults`.
///
/// Mutations to the published properties are mirrored to `UserDefaults` via
/// `didSet` so a fresh launch restores the user's session.
@MainActor
final class AppState: ObservableObject {
    private static let defaults = UserDefaults.standard

    private enum Keys {
        static let isLoggedIn = "ConnectIn.isLoggedIn"
        static let hasCompletedOnboarding = "ConnectIn.hasCompletedOnboarding"
        static let currentUser = "ConnectIn.currentUser"
        static let isDemoMode = "ConnectIn.isDemoMode"
        static let quizResult = "ConnectIn.quizResult"
        static let subscription = "ConnectIn.subscription"
    }

    // MARK: - Published properties

    @Published var isLoggedIn: Bool {
        didSet { Self.defaults.set(isLoggedIn, forKey: Keys.isLoggedIn) }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet { Self.defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    @Published var currentUser: User? {
        didSet {
            if let user = currentUser, let data = try? JSONEncoder().encode(user) {
                Self.defaults.set(data, forKey: Keys.currentUser)
            } else {
                Self.defaults.removeObject(forKey: Keys.currentUser)
            }
        }
    }

    @Published var isDemoMode: Bool {
        didSet { Self.defaults.set(isDemoMode, forKey: Keys.isDemoMode) }
    }

    @Published var quizResult: QuizResult? {
        didSet {
            if let result = quizResult, let data = try? JSONEncoder().encode(result) {
                Self.defaults.set(data, forKey: Keys.quizResult)
            } else {
                Self.defaults.removeObject(forKey: Keys.quizResult)
            }
        }
    }

    @Published var subscription: Subscription = .inactive {
        didSet {
            if let data = try? JSONEncoder().encode(subscription) {
                Self.defaults.set(data, forKey: Keys.subscription)
            }
        }
    }

    @Published var selectedTab: MainTab = .dashboard

    /// Single source of truth for routing. RootView reads this to decide which
    /// flow to render, eliminating any chance of intermediate inconsistent
    /// state between `isLoggedIn` and `hasCompletedOnboarding` mid-transaction.
    enum Phase: Equatable {
        case loggedOut
        case onboarding
        case loggedIn
    }

    var phase: Phase {
        if !isLoggedIn { return .loggedOut }
        if !hasCompletedOnboarding { return .onboarding }
        return .loggedIn
    }

    /// Whether the current user can use Pro features.
    ///
    /// Mentors are always free — they're the supply side of the marketplace,
    /// so we don't put a paywall in front of them. Mentees unlock Pro by
    /// trialing or subscribing. This property is the single check views use
    /// before deciding to show a paywall sheet.
    var hasPremiumAccess: Bool {
        if currentUser?.role == .mentor { return true }
        return subscription.hasAccess
    }

    /// True iff the logged-in user is a mentor. Used to dispatch role-
    /// specific dashboards, hide subscription UI, etc.
    var isMentor: Bool {
        currentUser?.role == .mentor
    }

    // MARK: - Init

    init() {
        // didSet is not invoked during init, so these initial assignments do
        // not write back to UserDefaults — exactly what we want.
        self.isLoggedIn = Self.defaults.bool(forKey: Keys.isLoggedIn)
        self.hasCompletedOnboarding = Self.defaults.bool(forKey: Keys.hasCompletedOnboarding)
        self.isDemoMode = Self.defaults.bool(forKey: Keys.isDemoMode)
        if let data = Self.defaults.data(forKey: Keys.currentUser),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
        } else {
            self.currentUser = nil
        }
        if let data = Self.defaults.data(forKey: Keys.quizResult),
           let result = try? JSONDecoder().decode(QuizResult.self, from: data) {
            self.quizResult = result
        } else {
            self.quizResult = nil
        }
        if let data = Self.defaults.data(forKey: Keys.subscription),
           let sub = try? JSONDecoder().decode(Subscription.self, from: data) {
            self.subscription = sub
        } else {
            self.subscription = .inactive
        }
    }

    // MARK: - Auth flow
    //
    // We intentionally do NOT wrap these mutations in `withAnimation`. The
    // `RootView` applies `.animation(_:value:)` to the routing changes, and
    // wrapping multiple `@Published` mutations in `withAnimation` here was
    // causing SwiftUI to render intermediate inconsistent states (each
    // mutation triggers `objectWillChange`) — which manifested as logout not
    // actually swapping back to `LoginView`.

    /// Used to mock a returning, fully-onboarded user (e.g. tapping "Sign in").
    func login() {
        currentUser = SampleData.currentUser
        hasCompletedOnboarding = true
        selectedTab = .dashboard
        isLoggedIn = true
    }

    /// Used after a successful sign-up — user is authenticated but still has
    /// to pick a role and finish profile creation. The role defaults to
    /// `.mentee`; `RoleSelectionView` flips it to `.mentor` on the
    /// `ProfileViewModel` side if the user picks the mentor card.
    func startOnboarding(email: String, fullName: String) {
        let user = User(
            id: UUID(),
            email: email,
            fullName: fullName,
            role: .mentee,
            profileImageURL: nil,
            bio: "",
            interests: [],
            goals: [],
            university: "",
            major: "",
            graduationYear: Calendar.current.component(.year, from: Date()) + 1,
            isFirstGen: false,
            jobTitle: nil,
            company: nil,
            yearsExperience: nil,
            availability: nil,
            maxMentees: nil,
            createdAt: Date()
        )
        currentUser = user
        hasCompletedOnboarding = false
        isLoggedIn = true
    }

    func logout() {
        // Order matters: clear flags first, drop user last. `isLoggedIn` is
        // the property RootView observes for its primary routing decision, so
        // updating it last guarantees views see fully-cleared state.
        hasCompletedOnboarding = false
        isDemoMode = false
        quizResult = nil
        subscription = .inactive
        selectedTab = .dashboard
        currentUser = nil
        isLoggedIn = false
    }

    func completeOnboarding(user: User) {
        currentUser = user
        selectedTab = .dashboard
        hasCompletedOnboarding = true
    }

    /// Replace the current user (used by the in-app profile editor).
    func updateUser(_ user: User) {
        currentUser = user
    }

    // MARK: - Demo mode

    /// Bypass auth + onboarding and drop straight into a fully-populated demo
    /// session as Sofia Martinez. Also drops the user into an active Pro
    /// trial so every premium feature is unlocked for the demo.
    func enterDemoMode() {
        currentUser = SampleData.currentUser
        hasCompletedOnboarding = true
        isDemoMode = true
        selectedTab = .dashboard
        if !subscription.hasAccess {
            startFreeTrial()
        }
        isLoggedIn = true
    }

    // MARK: - Subscription

    func startFreeTrial() {
        let now = Date()
        let renews = Calendar.current.date(byAdding: .day, value: Subscription.trialDays, to: now)
        subscription = Subscription(
            status: .trialing,
            startedAt: now,
            renewsAt: renews
        )
    }

    func subscribeNow() {
        let now = Date()
        let renews = Calendar.current.date(byAdding: .month, value: 1, to: now)
        subscription = Subscription(
            status: .active,
            startedAt: subscription.startedAt ?? now,
            renewsAt: renews
        )
    }

    func cancelSubscription() {
        subscription = Subscription(
            status: .expired,
            startedAt: subscription.startedAt,
            renewsAt: nil
        )
    }
}
