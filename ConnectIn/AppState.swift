//
//  AppState.swift
//  ConnectIn
//

import Foundation

enum AuthRoute: Hashable {
    case signup
}

enum OnboardingRoute: Hashable {
    case profileCreation(UserRole)
}

@MainActor
final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var currentUser: User?

    func login() {
        isLoggedIn = true

        if currentUser == nil {
            currentUser = User(
                id: UUID(),
                email: "new.user@connectin.app",
                fullName: "New User",
                role: .student,
                profileImageURL: nil,
                bio: "",
                interests: [],
                goals: [],
                university: "",
                major: "",
                graduationYear: Calendar.current.component(.year, from: Date()),
                isFirstGen: false,
                createdAt: Date()
            )
        }
    }

    func logout() {
        isLoggedIn = false
        hasCompletedOnboarding = false
        currentUser = nil
    }

    func completeOnboarding(user: User) {
        currentUser = user
        hasCompletedOnboarding = true
    }
}
