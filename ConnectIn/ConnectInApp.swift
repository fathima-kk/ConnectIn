//
//  ConnectInApp.swift
//  ConnectIn
//
//  Created by Fathima K K on 5/3/26.
//

import SwiftUI

@main
struct ConnectInApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var connectionsManager = ConnectionsManager()
    @StateObject private var sessionsManager = SessionsManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(connectionsManager)
                .environmentObject(sessionsManager)
                // HIG: support Dynamic Type, but cap before the largest
                // accessibility sizes so dense card layouts (mentor cards,
                // session tiles) stay readable instead of blowing out.
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
}

/// Root coordinator. Shows the splash for ~2s, then routes the user into auth,
/// onboarding, or the main tab bar based on `AppState`.
struct RootView: View {
    @EnvironmentObject private var appState: AppState

    @State private var hasFinishedSplash: Bool = false
    @State private var authPath = NavigationPath()
    @State private var onboardingPath = NavigationPath()
    @StateObject private var profileViewModel = ProfileViewModel()

    /// Splash should hide once the timer fires OR if the user dropped straight
    /// into demo mode via the triple-tap escape hatch on the logo.
    private var splashIsActive: Bool {
        !hasFinishedSplash && !appState.isDemoMode
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            if splashIsActive {
                SplashView()
                    .transition(.opacity)
            } else {
                switch appState.phase {
                case .loggedOut:
                    authFlow
                        .transition(.opacity)
                case .onboarding:
                    onboardingFlow
                        .transition(.opacity)
                case .loggedIn:
                    ContentView()
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: splashIsActive)
        .animation(.easeInOut(duration: 0.35), value: appState.phase)
        .task {
            try? await Task.sleep(for: .seconds(2))
            hasFinishedSplash = true
        }
        .onChange(of: appState.phase) { _, newPhase in
            // Reset any pushed routes whenever we transition between flows so
            // the user always lands on the root of the new flow.
            switch newPhase {
            case .loggedOut:
                authPath = NavigationPath()
                onboardingPath = NavigationPath()
            case .onboarding:
                onboardingPath = NavigationPath()
            case .loggedIn:
                authPath = NavigationPath()
                onboardingPath = NavigationPath()
            }
        }
    }

    private var authFlow: some View {
        NavigationStack(path: $authPath) {
            LoginView()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .signup:
                        SignupView()
                    }
                }
        }
    }

    /// Onboarding flow lives behind a single `NavigationStack`. The
    /// destination switch fans out to either the mentee or the mentor 3-step
    /// flow based on the route value pushed by `RoleSelectionView`.
    private var onboardingFlow: some View {
        NavigationStack(path: $onboardingPath) {
            RoleSelectionView()
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                    // Mentee flow
                    case .basicInfo(let role):
                        ProfileCreationView(role: role)
                    case .interests:
                        ProfileInterestsView()
                    case .goals:
                        ProfileGoalsView()

                    // Mentor flow
                    case .mentorBasicInfo:
                        MentorBasicInfoView()
                    case .mentorExpertise:
                        MentorExpertiseView()
                    case .mentorMentorship:
                        MentorMentorshipView()
                    }
                }
        }
        .environmentObject(profileViewModel)
    }
}

#Preview("Logged out") {
    RootView()
        .environmentObject(AppState())
        .environmentObject(ConnectionsManager())
        .environmentObject(SessionsManager())
}
