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

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
        }
    }
}

private struct AppRootView: View {
    @EnvironmentObject private var appState: AppState

    @State private var showSplash = true
    @State private var authPath: [AuthRoute] = []
    @State private var onboardingPath: [OnboardingRoute] = []

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if !appState.isLoggedIn {
                NavigationStack(path: $authPath) {
                    LoginView()
                        .navigationDestination(for: AuthRoute.self) { route in
                            switch route {
                            case .signup:
                                SignupView()
                            }
                        }
                }
                .transition(.opacity)
            } else if !appState.hasCompletedOnboarding {
                NavigationStack(path: $onboardingPath) {
                    RoleSelectionView { selectedRole in
                        onboardingPath.append(.profileCreation(selectedRole))
                    }
                    .navigationDestination(for: OnboardingRoute.self) { route in
                        switch route {
                        case .profileCreation(let selectedRole):
                            ProfileCreationView(selectedRole: selectedRole)
                        }
                    }
                }
                .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showSplash)
        .animation(.easeInOut(duration: 0.35), value: appState.isLoggedIn)
        .animation(.easeInOut(duration: 0.35), value: appState.hasCompletedOnboarding)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
        .onChange(of: appState.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                authPath = []
            } else {
                onboardingPath = []
            }
        }
    }
}
