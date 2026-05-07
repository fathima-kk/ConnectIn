//
//  SplashView.swift
//  ConnectIn
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacing) {
                Text("ConnectIn")
                    .connectInLargeTitle()
                    .foregroundStyle(AppTheme.Colors.primary)
                Text("Free mentorship for anyone building a career in tech—students, career switchers, and self-taught learners welcome.")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                Spacer()
                NavigationLink("Get started") {
                    LoginView()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.Colors.accent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SplashView()
}
