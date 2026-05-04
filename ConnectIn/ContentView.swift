//
//  ContentView.swift
//  ConnectIn
//
//  Created by Fathima K K on 5/3/26.
//

import SwiftUI

struct ContentView: View {
    /// Selection type for the root tab bar (not SwiftUI's `Tab` view type).
    enum MainTab: Hashable {
        case dashboard
        case browse
        case profile
    }

    @State private var selectedTab: MainTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .dashboard) {
                NavigationStack {
                    DashboardView()
                }
            }

            Tab("Browse", systemImage: "person.2.fill", value: .browse) {
                BrowseMentorsView()
            }

            Tab("Profile", systemImage: "person.crop.circle.fill", value: .profile) {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(AppTheme.Colors.accent)
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    ContentView()
}
