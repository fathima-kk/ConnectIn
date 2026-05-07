//
//  MentorCard.swift
//  ConnectIn
//

import SwiftUI
import UIKit

private struct MentorCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct MentorCard: View {
    let mentor: Mentor
    var onTap: () -> Void

    private var jobLine: String {
        "\(mentor.jobTitle) @ \(mentor.company)"
    }

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                profileImage

                VStack(alignment: .leading, spacing: 6) {
                    Text(mentor.user.fullName)
                        .connectInHeadline()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .lineLimit(1)

                    Text(jobLine)
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineLimit(2)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(mentor.expertise, id: \.self) { skill in
                                TagView(text: skill, color: .teal)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                matchBadge

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .padding(14)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: AppTheme.Colors.textPrimary.opacity(0.08), radius: 10, y: 4)
        }
        .buttonStyle(MentorCardPressStyle())
    }

    @ViewBuilder
    private var profileImage: some View {
        Group {
            if let urlString = mentor.user.profileImageURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholderCircle
                    }
                }
            } else {
                placeholderCircle
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
    }

    private var placeholderCircle: some View {
        Image(systemName: "person.fill")
            .font(.system(size: 26))
            .foregroundStyle(AppTheme.Colors.secondary.opacity(0.8))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.background)
    }

    private var matchBadge: some View {
        Text("\(mentor.matchPercentage)%")
            .font(.system(size: 11, weight: .bold, design: .default))
            .foregroundStyle(AppTheme.Colors.cardBackground)
            .frame(width: 44, height: 44)
            .background(AppTheme.Colors.secondary, in: Circle())
    }
}

#Preview {
    MentorCard(mentor: SampleData.mentors[0]) {}
        .padding()
        .background(AppTheme.Colors.background)
}
