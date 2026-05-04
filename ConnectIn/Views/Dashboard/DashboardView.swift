//
//  DashboardView.swift
//  ConnectIn
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        List {
            Section("Welcome") {
                Text("Connect with mentors who fit your goals—whether you’re in school, switching careers, or learning on your own.")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            Section("Shortcuts") {
                NavigationLink("Browse mentors") {
                    BrowseMentorsView()
                }
                NavigationLink("Splash flow") {
                    SplashView()
                }
            }
        }
        .navigationTitle("Home")
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
