//
//  SplashView.swift
//  ConnectIn
//

import SwiftUI

/// Branded splash screen. Held for ~2 seconds by the root coordinator before
/// transitioning to the auth, onboarding, or main app flow.
///
/// **Demo escape hatch:** triple-tap the logo to instantly enter demo mode as
/// Sofia Martinez (skipping splash, auth, and onboarding).
struct SplashView: View {
    @EnvironmentObject private var appState: AppState

    @State private var isPulsing = false
    @State private var hasAppeared = false

    private static let gradient = LinearGradient(
        colors: [Color(hex: "#2E1065"), Color(hex: "#5B21B6")],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack {
            Self.gradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                logo
                    .padding(.bottom, 8)
                    .onTapGesture(count: 3) {
                        appState.enterDemoMode()
                    }

                Text("ConnectIn")
                    .font(.system(size: 44, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 8)

                Text("Find Your Guide")
                    .connectInCaption()
                    .fontWeight(.medium)
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundStyle(AppTheme.Colors.accent)
                    .opacity(hasAppeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                hasAppeared = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    private var logo: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.accent.opacity(0.18))
                .frame(width: 160, height: 160)
                .scaleEffect(isPulsing ? 1.15 : 0.95)
                .blur(radius: 4)

            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 120, height: 120)

            Image(systemName: "person.2.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.white)
                .scaleEffect(isPulsing ? 1.05 : 1.0)
        }
        .accessibilityHidden(true)
        .accessibilityHint("Triple-tap to enter demo mode")
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState())
}
