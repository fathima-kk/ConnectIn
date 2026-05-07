//
//  DashboardView.swift
//  ConnectIn
//

import SwiftUI

struct DashboardView: View {
    private let user = SampleData.currentUser
    private let featuredMentors = Array(SampleData.mentors.prefix(3))

    private var greetingName: String {
        user.fullName.split(separator: " ").first.map(String.init) ?? user.fullName
    }

    private var pendingMatches: Int {
        SampleData.matches.filter { $0.status == .pending }.count
    }

    private var activeMatches: Int {
        SampleData.matches.filter { $0.status == .accepted }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                heroHeader

                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("Quick actions")
                    HStack(spacing: 12) {
                        NavigationLink {
                            BrowseMentorsView()
                        } label: {
                            DashboardActionTile(
                                icon: "person.2.fill",
                                title: "Find mentors",
                                subtitle: "Browse profiles",
                                iconTint: AppTheme.Colors.secondary
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ProfileView()
                        } label: {
                            DashboardActionTile(
                                icon: "person.crop.circle",
                                title: "Your profile",
                                subtitle: "Edit & visibility",
                                iconTint: AppTheme.Colors.primary
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        sectionTitle("Suggested for you")
                        Spacer()
                        NavigationLink {
                            BrowseMentorsView()
                        } label: {
                            Text("See all")
                                .connectInCaption()
                                .fontWeight(.semibold)
                                .foregroundStyle(AppTheme.Colors.secondary)
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(featuredMentors) { mentor in
                                NavigationLink(value: mentor) {
                                    DashboardMentorSuggestionCard(mentor: mentor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.trailing, 4)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("Mentorship activity")
                    VStack(spacing: 0) {
                        activityRow(
                            icon: "paperplane.fill",
                            title: "Pending requests",
                            value: "\(pendingMatches)",
                            tint: AppTheme.Colors.accent
                        )
                        Divider().padding(.leading, 52)
                        activityRow(
                            icon: "checkmark.circle.fill",
                            title: "Active connections",
                            value: "\(activeMatches)",
                            tint: AppTheme.Colors.success
                        )
                    }
                    .padding(4)
                    .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: AppTheme.Colors.textPrimary.opacity(0.06), radius: 12, y: 4)
                }

                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("Get the most from ConnectIn")
                    Text("Send a short intro when you reach out—mention your goals and what you’d like to learn. Mentors respond faster to specific, respectful asks.")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(hex: "#E5E7EB"), lineWidth: 1)
                }

                NavigationLink {
                    SplashView()
                } label: {
                    HStack {
                        Text("How ConnectIn works")
                            .connectInBody()
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.Colors.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Mentor.self) { mentor in
            MentorDetailView(mentor: mentor)
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hi, \(greetingName)")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundStyle(.white)
            Text("Build meaningful connections with mentors who’ve been where you want to go.")
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.primary,
                            AppTheme.Colors.primary.opacity(0.85),
                            AppTheme.Colors.secondary.opacity(0.95),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .shadow(color: AppTheme.Colors.primary.opacity(0.35), radius: 20, y: 10)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .default))
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .textCase(.uppercase)
            .tracking(0.6)
    }

    private func activityRow(icon: String, title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            Text(title)
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Spacer()
            Text(value)
                .connectInHeadline()
                .foregroundStyle(AppTheme.Colors.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Subviews

private struct DashboardActionTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconTint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconTint)
                .frame(width: 44, height: 44)
                .background(iconTint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 148)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: AppTheme.Colors.textPrimary.opacity(0.06), radius: 12, y: 4)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(hex: "#E8ECF4"), lineWidth: 1)
        }
    }
}

private struct DashboardMentorSuggestionCard: View {
    let mentor: Mentor

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                mentorAvatar
                Spacer(minLength: 0)
                Text("\(mentor.matchPercentage)%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.cardBackground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.secondary, in: Capsule())
            }
            Text(mentor.user.fullName)
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text("\(mentor.jobTitle) · \(mentor.company)")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            TagFlowView(tags: Array(mentor.expertise.prefix(2)), color: .teal, spacing: 6)
        }
        .padding(16)
        .frame(width: 220, alignment: .leading)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: AppTheme.Colors.textPrimary.opacity(0.07), radius: 10, y: 4)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(hex: "#E8ECF4"), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var mentorAvatar: some View {
        Group {
            if let s = mentor.user.profileImageURL, let url = URL(string: s) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Image(systemName: "person.fill")
            .font(.system(size: 18))
            .foregroundStyle(AppTheme.Colors.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.background)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
