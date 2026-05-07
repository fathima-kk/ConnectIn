//
//  SignupView.swift
//  ConnectIn
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agreedToTerms: Bool = false
    @State private var isLoading: Bool = false
    @State private var hasAttemptedSubmit: Bool = false

    // MARK: - Validation

    private var nameError: String? {
        guard shouldShowError(for: fullName) else { return nil }
        return fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Please enter your full name."
            : nil
    }

    private var emailError: String? {
        guard shouldShowError(for: email) else { return nil }
        return Self.isValidEmail(email) ? nil : "Enter a valid email address."
    }

    private var passwordError: String? {
        guard shouldShowError(for: password) else { return nil }
        return password.count >= 8 ? nil : "Password must be at least 8 characters."
    }

    private var confirmPasswordError: String? {
        guard shouldShowError(for: confirmPassword) else { return nil }
        return confirmPassword == password ? nil : "Passwords do not match."
    }

    private var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            Self.isValidEmail(email) &&
            password.count >= 8 &&
            confirmPassword == password &&
            agreedToTerms
    }

    private func shouldShowError(for field: String) -> Bool {
        hasAttemptedSubmit || !field.isEmpty
    }

    private static func isValidEmail(_ raw: String) -> Bool {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                form
                termsRow
                createButton
                signInLink
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create Account")
                .connectInLargeTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Join ConnectIn today")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    private var form: some View {
        VStack(spacing: 16) {
            CustomTextField(
                label: "Full Name",
                placeholder: "Jane Doe",
                text: $fullName,
                icon: "person.fill",
                isSecure: false,
                errorMessage: nameError
            )
            .textContentType(.name)
            .textInputAutocapitalization(.words)

            CustomTextField(
                label: "Email",
                placeholder: "you@example.com",
                text: $email,
                icon: "envelope.fill",
                isSecure: false,
                errorMessage: emailError
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocorrectionDisabled(true)

            VStack(alignment: .leading, spacing: 6) {
                CustomTextField(
                    label: "Password",
                    placeholder: "At least 8 characters",
                    text: $password,
                    icon: "lock.fill",
                    isSecure: true,
                    errorMessage: passwordError
                )
                .textContentType(.newPassword)

                if passwordError == nil {
                    Text("Use at least 8 characters.")
                        .connectInCaption()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            CustomTextField(
                label: "Confirm Password",
                placeholder: "Re-enter your password",
                text: $confirmPassword,
                icon: "lock.fill",
                isSecure: true,
                errorMessage: confirmPasswordError
            )
            .textContentType(.newPassword)
        }
    }

    private var termsRow: some View {
        Button {
            agreedToTerms.toggle()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(agreedToTerms ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)

                termsLabel
            }
        }
        .buttonStyle(.plain)
    }

    private var termsLabel: some View {
        let terms = Text("Terms")
            .foregroundColor(AppTheme.Colors.accent)
            .underline()
        let privacy = Text("Privacy Policy")
            .foregroundColor(AppTheme.Colors.accent)
            .underline()
        return Text("I agree to the \(terms) & \(privacy)")
            .connectInBody()
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .multilineTextAlignment(.leading)
    }

    private var createButton: some View {
        PrimaryButton(
            title: "Create Account",
            style: .primary,
            isLoading: isLoading,
            isDisabled: !isFormValid
        ) {
            submit()
        }
    }

    private var signInLink: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Button {
                dismiss()
            } label: {
                Text("Sign in")
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    // MARK: - Actions

    private func submit() {
        hasAttemptedSubmit = true
        guard isFormValid else { return }
        isLoading = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            isLoading = false
            appState.startOnboarding(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AppState())
    }
}
