//
//  ProfileCreationView.swift
//  ConnectIn
//

import SwiftUI

struct ProfileCreationView: View {
    @EnvironmentObject private var appState: AppState

    let selectedRole: UserRole?

    init(selectedRole: UserRole? = nil) {
        self.selectedRole = selectedRole
    }

    @State private var headline = ""
    @State private var bio = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CustomTextField(
                    label: "Headline",
                    placeholder: "e.g. Aspiring product manager",
                    text: $headline,
                    errorMessage: nil
                )
                CustomTextEditor(
                    label: "Bio",
                    text: $bio,
                    placeholder: "Share your background and what you want from mentorship…",
                    showsCharacterCount: true
                )

                PrimaryButton(title: "Save profile", style: .primary, isLoading: false) {
                    completeOnboarding()
                }
            }
            .padding()
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Your profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func completeOnboarding() {
        let baseUser = appState.currentUser
        let newUser = User(
            id: baseUser?.id ?? UUID(),
            email: baseUser?.email ?? "new.user@connectin.app",
            fullName: baseUser?.fullName ?? "New User",
            role: selectedRole ?? baseUser?.role ?? .student,
            profileImageURL: baseUser?.profileImageURL,
            bio: bio,
            interests: baseUser?.interests ?? [],
            goals: headline.isEmpty ? (baseUser?.goals ?? []) : [headline],
            university: baseUser?.university ?? "",
            major: baseUser?.major ?? "",
            graduationYear: baseUser?.graduationYear ?? Calendar.current.component(.year, from: Date()),
            isFirstGen: baseUser?.isFirstGen ?? false,
            createdAt: baseUser?.createdAt ?? Date()
        )

        appState.completeOnboarding(user: newUser)
    }
}

#Preview {
    NavigationStack {
        ProfileCreationView(selectedRole: .student)
            .environmentObject(AppState())
    }
}
