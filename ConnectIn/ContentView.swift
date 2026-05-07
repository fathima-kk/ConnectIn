//
//  ContentView.swift
//  ConnectIn
//
//  Created by Fathima K K on 5/3/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var connectionsManager: ConnectionsManager
    @EnvironmentObject private var sessionsManager: SessionsManager

    /// Pending-mentor-request badge is mentee-only — mentors see incoming
    /// mentee asks on their dashboard instead.
    private var browseBadgeCount: Int {
        appState.isMentor ? 0 : connectionsManager.pendingCount
    }

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: MainTab.dashboard) {
                NavigationStack {
                    DashboardView()
                        .navigationDestination(for: Mentor.self) { mentor in
                            MentorDetailView(mentor: mentor)
                        }
                }
            }

            Tab("Browse", systemImage: "magnifyingglass", value: MainTab.browse) {
                NavigationStack {
                    BrowseMentorsView()
                        .navigationDestination(for: Mentor.self) { mentor in
                            MentorDetailView(mentor: mentor)
                        }
                }
            }
            .badge(browseBadgeCount)

            Tab("Sessions", systemImage: "calendar", value: MainTab.sessions) {
                SessionsView()
            }
            .badge(sessionsManager.upcomingSessions.count)

            Tab("Profile", systemImage: "person.fill", value: MainTab.profile) {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(AppTheme.Colors.secondary)
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    ContentView()
        .environmentObject({
            let s = AppState()
            s.currentUser = SampleData.currentUser
            s.isLoggedIn = true
            s.hasCompletedOnboarding = true
            return s
        }())
        .environmentObject(ConnectionsManager())
        .environmentObject(SessionsManager())
}
