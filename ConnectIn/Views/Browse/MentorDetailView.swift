//
//  MentorDetailView.swift
//  ConnectIn
//

import SwiftUI

struct MentorDetailView: View {
    let mentor: Mentor

    private var roleLine: String {
        "\(mentor.jobTitle) · \(mentor.company)"
    }

    var body: some View {
        List {
            Section {
                ProfileHeader(
                    imageURL: mentor.user.profileImageURL,
                    name: mentor.user.fullName,
                    role: mentor.user.role,
                    subtitle: roleLine,
                    isEditable: false,
                    onEditTap: nil
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("About") {
                Text(mentor.user.bio)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }

            Section("Role") {
                LabeledContent("Experience", value: "\(mentor.yearsExperience) yrs")
                LabeledContent("Availability", value: mentor.availability)
                LabeledContent("Mentees", value: "\(mentor.currentMentees) / \(mentor.maxMentees)")
                LabeledContent("Match score", value: "\(mentor.matchPercentage)%")
            }

            Section("Expertise") {
                TagFlowView(tags: mentor.expertise, color: .teal)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section {
                PrimaryButton(title: "Request match", style: .primary, isLoading: false) {}
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background)
        .navigationTitle("Mentor")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MentorDetailView(mentor: SampleData.mentors[0])
    }
}
