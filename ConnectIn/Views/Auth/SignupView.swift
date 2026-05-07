//
//  SignupView.swift
//  ConnectIn
//

import SwiftUI

struct SignupView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CustomTextField(
                    label: "Name",
                    placeholder: "Your name",
                    text: $name,
                    icon: "person.fill",
                    errorMessage: nil
                )
                CustomTextField(
                    label: "Email",
                    placeholder: "you@example.com",
                    text: $email,
                    icon: "envelope.fill",
                    errorMessage: nil
                )
                CustomTextField(
                    label: "Password",
                    placeholder: "Create a password",
                    text: $password,
                    icon: "lock.fill",
                    isSecure: true,
                    errorMessage: nil
                )

                PrimaryButton(title: "Create account", style: .primary, isLoading: false) {}

                NavigationLink("Choose role") {
                    RoleSelectionView()
                }
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Sign up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignupView()
    }
}
