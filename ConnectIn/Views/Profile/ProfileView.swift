//
//  ProfileView.swift
//  ConnectIn
//

import SwiftUI

struct ProfileView: View {
    private let user = SampleData.currentUser

    var body: some View {
        List {
            Section {
                ProfileHeader(
                    imageURL: user.profileImageURL,
                    name: user.fullName,
                    role: user.role,
                    subtitle: user.university,
                    isEditable: true,
                    onEditTap: {}
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Account") {
                LabeledContent("Email", value: user.email)
                LabeledContent("School / org", value: user.university)
                LabeledContent("Focus", value: user.major)
                NavigationLink("Edit profile") {
                    ProfileCreationView()
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background)
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
