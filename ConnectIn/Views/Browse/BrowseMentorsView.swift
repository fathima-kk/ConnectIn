//
//  BrowseMentorsView.swift
//  ConnectIn
//

import SwiftUI

struct BrowseMentorsView: View {
    @State private var path = NavigationPath()
    private let mentors = SampleData.mentors

    var body: some View {
        NavigationStack(path: $path) {
            List(mentors) { mentor in
                MentorCard(mentor: mentor) {
                    path.append(mentor)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .navigationTitle("Mentors")
            .navigationDestination(for: Mentor.self) { mentor in
                MentorDetailView(mentor: mentor)
            }
        }
    }
}

#Preview {
    BrowseMentorsView()
}
