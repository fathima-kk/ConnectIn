//
//  ProfileCreationView.swift
//  ConnectIn
//

import SwiftUI

struct ProfileCreationView: View {
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

                PrimaryButton(title: "Save profile", style: .primary, isLoading: false) {}
            }
            .padding()
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Your profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileCreationView()
    }
}
