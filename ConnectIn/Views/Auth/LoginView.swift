//
//  LoginView.swift
//  ConnectIn
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome Back")
                    .connectInTitle()
                    .foregroundStyle(AppTheme.Colors.primary)
                    .padding(.top, 16)

                Text("Sign in to continue")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                CustomTextField(
                    label: "Email",
                    placeholder: "you@example.com",
                    text: $email,
                    icon: "envelope.fill",
                    isSecure: false
                )

                CustomTextField(
                    label: "Password",
                    placeholder: "Enter your password",
                    text: $password,
                    icon: "lock.fill",
                    isSecure: true,
                    errorMessage: showError ? "Please enter valid email and password." : nil
                )

                Button("Forgot Password?") {}
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.accent)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                PrimaryButton(title: "Sign In", style: .primary, isLoading: isLoading) {
                    signIn()
                }

                HStack {
                    Rectangle()
                        .fill(Color(hex: "#D1D5DB"))
                        .frame(height: 1)
                    Text("or")
                        .connectInCaption()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Rectangle()
                        .fill(Color(hex: "#D1D5DB"))
                        .frame(height: 1)
                }

                PrimaryButton(title: "Continue with Google", style: .secondary, isLoading: false) {}

                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    NavigationLink("Sign up", value: AuthRoute.signup)
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.accent)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .background(AppTheme.Colors.background)
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func signIn() {
        showError = false

        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError = true
            return
        }

        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            appState.login()
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AppState())
    }
}
