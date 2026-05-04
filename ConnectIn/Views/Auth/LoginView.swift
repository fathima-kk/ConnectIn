//
//  LoginView.swift
//  ConnectIn
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CustomTextField(
                    label: "Email",
                    placeholder: "you@example.com",
                    text: $email,
                    icon: "envelope.fill",
                    isSecure: false,
                    errorMessage: nil
                )
                CustomTextField(
                    label: "Password",
                    placeholder: "Enter your password",
                    text: $password,
                    icon: "lock.fill",
                    isSecure: true,
                    errorMessage: errorMessage
                )

                PrimaryButton(title: "Log in", style: .primary, isLoading: false) {}

                NavigationLink("Create account") {
                    SignupView()
                }
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Log in")
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
