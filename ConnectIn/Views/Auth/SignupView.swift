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
    @State private var showValidationErrors: Bool = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Create Account")
                    .connectInTitle()
                    .foregroundStyle(AppTheme.Colors.primary)
                    .padding(.top, 16)

                Text("Join ConnectIn today")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                CustomTextField(
                    label: "Full Name",
                    placeholder: "Enter your full name",
                    text: $fullName,
                    icon: "person.fill",
                    errorMessage: shouldShowNameError ? "Name is required." : nil
                )
                CustomTextField(
                    label: "Email",
                    placeholder: "you@example.com",
                    text: $email,
                    icon: "envelope.fill",
                    errorMessage: shouldShowEmailError ? "Enter a valid email address." : nil
                )
                CustomTextField(
                    label: "Password",
                    placeholder: "Create a password",
                    text: $password,
                    icon: "lock.fill",
                    isSecure: true,
                    errorMessage: shouldShowPasswordError ? "Password must be at least 8 characters." : nil
                )
                Text("Use at least 8 characters.")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                CustomTextField(
                    label: "Confirm Password",
                    placeholder: "Re-enter your password",
                    text: $confirmPassword,
                    icon: "lock.fill",
                    isSecure: true,
                    errorMessage: shouldShowConfirmPasswordError ? "Passwords do not match." : nil
                )

                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        agreedToTerms.toggle()
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundStyle(agreedToTerms ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
                                .font(.headline)

                            HStack(spacing: 0) {
                                Text("I agree to ")
                                    .connectInBody()
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                Button("Terms") {}
                                    .connectInBody()
                                    .foregroundStyle(AppTheme.Colors.accent)
                                Text(" & ")
                                    .connectInBody()
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                Button("Privacy Policy") {}
                                    .connectInBody()
                                    .foregroundStyle(AppTheme.Colors.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    if shouldShowTermsError {
                        Text("You must accept Terms & Privacy Policy.")
                            .connectInCaption()
                            .foregroundStyle(AppTheme.Colors.error)
                    }
                }

                PrimaryButton(
                    title: "Create Account",
                    style: .primary,
                    isLoading: false,
                    isDisabled: !isFormValid
                ) {
                    submitSignup()
                }

                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    Button("Sign in") {
                        dismiss()
                    }
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.accent)
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .background(AppTheme.Colors.background)
        .scrollIndicators(.hidden)
        .navigationTitle("Sign up")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isNameValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isEmailValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^\S+@\S+\.\S+$"#
        return trimmedEmail.range(of: pattern, options: .regularExpression) != nil
    }

    private var isPasswordValid: Bool {
        password.count >= 8
    }

    private var isConfirmPasswordValid: Bool {
        !confirmPassword.isEmpty && confirmPassword == password
    }

    private var isFormValid: Bool {
        isNameValid && isEmailValid && isPasswordValid && isConfirmPasswordValid && agreedToTerms
    }

    private var shouldShowNameError: Bool {
        showValidationErrors || !fullName.isEmpty
            ? !isNameValid
            : false
    }

    private var shouldShowEmailError: Bool {
        showValidationErrors || !email.isEmpty
            ? !isEmailValid
            : false
    }

    private var shouldShowPasswordError: Bool {
        showValidationErrors || !password.isEmpty
            ? !isPasswordValid
            : false
    }

    private var shouldShowConfirmPasswordError: Bool {
        showValidationErrors || !confirmPassword.isEmpty
            ? !isConfirmPasswordValid
            : false
    }

    private var shouldShowTermsError: Bool {
        showValidationErrors && !agreedToTerms
    }

    private func submitSignup() {
        showValidationErrors = true
        guard isFormValid else { return }
        appState.login()
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AppState())
    }
}
