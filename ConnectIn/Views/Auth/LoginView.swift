//
//  LoginView.swift
//  ConnectIn
//

import SwiftUI

/// Routes pushed onto the auth `NavigationStack`.
enum AuthRoute: Hashable {
    case signup
}

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !password.isEmpty &&
            !isLoading
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                form
                signInButton
                divider
                googleButton
                signupLink
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .navigationBarBackButtonHidden(true)
        .alert("Couldn't sign in", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter both an email and a password to continue.")
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome Back")
                .connectInLargeTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Sign in to continue")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    private var form: some View {
        VStack(alignment: .trailing, spacing: 16) {
            CustomTextField(
                label: "Email",
                placeholder: "you@example.com",
                text: $email,
                icon: "envelope.fill",
                isSecure: false,
                errorMessage: nil
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocorrectionDisabled(true)

            CustomTextField(
                label: "Password",
                placeholder: "Enter your password",
                text: $password,
                icon: "lock.fill",
                isSecure: true,
                errorMessage: nil
            )
            .textContentType(.password)

            Button {
                // Placeholder for forgot-password flow.
            } label: {
                Text("Forgot Password?")
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            .buttonStyle(.plain)
        }
    }

    private var signInButton: some View {
        PrimaryButton(
            title: "Sign In",
            style: .primary,
            isLoading: isLoading,
            isDisabled: !canSubmit
        ) {
            attemptLogin()
        }
    }

    private var divider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(AppTheme.Colors.divider)
                .frame(height: 1)
            Text("or")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Rectangle()
                .fill(AppTheme.Colors.divider)
                .frame(height: 1)
        }
    }

    private var googleButton: some View {
        Button {
            // Placeholder for Google sign-in.
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "globe")
                    .font(.system(size: 18, weight: .semibold))
                Text("Continue with Google")
                    .connectInHeadline()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(AppTheme.Colors.inputBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var signupLink: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
            NavigationLink(value: AuthRoute.signup) {
                Text("Sign up")
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func attemptLogin() {
        guard canSubmit else {
            showError = true
            return
        }
        isLoading = true
        Task {
            try? await Task.sleep(for: .seconds(1))
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
