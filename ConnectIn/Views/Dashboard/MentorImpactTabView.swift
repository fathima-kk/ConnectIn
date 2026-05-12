//
//  MentorImpactTabView.swift
//  ConnectIn
//
//  Second tab for mentors: mentee feedback, ratings, and light coaching so the
//  space feels motivating—not a dead-end after hiding mentor discovery.
//

import SwiftUI

struct MentorImpactTabView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var sessionsManager: SessionsManager

    private let reviews = SampleData.mentorReviewHighlights

    private var user: User {
        appState.currentUser ?? SampleData.currentUser
    }

    private var greetingName: String {
        user.fullName.split(separator: " ").first.map(String.init) ?? user.fullName
    }

    private var averageStars: Double {
        guard !reviews.isEmpty else { return 0 }
        let sum = reviews.reduce(0) { $0 + $1.stars }
        return Double(sum) / Double(reviews.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summaryCard
                momentumRow
                reviewsSection
                profileMotivationCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Impact")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("You’re making a difference, \(greetingName)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(String(format: "%.1f", averageStars))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.accent)
                VStack(alignment: .leading, spacing: 2) {
                    starRow(
                        filled: Int(round(averageStars)),
                        accessibilityLabel: "Average \(String(format: "%.1f", averageStars)) out of 5 stars from recent private reviews"
                    )
                    Text("Average from recent private reviews")
                        .connectInCaption()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            Text("Mentees share these after sessions. They’re only visible to you—use them as fuel and to tune how you show up.")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.secondary.opacity(0.45),
                            AppTheme.Colors.accent.opacity(0.35),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }

    private func starRow(filled: Int, accessibilityLabel: String) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < min(filled, 5) ? "star.fill" : "star")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(i < min(filled, 5) ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary.opacity(0.35))
            }
        }
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Momentum

    private var momentumRow: some View {
        HStack(spacing: 10) {
            momentumTile(
                value: "\(sessionsManager.completedSessionCount)",
                label: "Sessions done",
                icon: "video.fill"
            )
            momentumTile(
                value: "\(sessionsManager.milestoneCount)",
                label: "Wins unlocked",
                icon: "flag.checkered"
            )
        }
    }

    private func momentumTile(value: String, label: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.secondary)
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(label)
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppTheme.Colors.cardBorder, lineWidth: 1)
        }
    }

    // MARK: - Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("What mentees said recently")

            ForEach(reviews) { item in
                reviewCard(item)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .textCase(.uppercase)
            .tracking(0.6)
    }

    private func reviewCard(_ item: MentorReviewHighlight) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(item.menteeGivenName)
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                starRow(
                    filled: item.stars,
                    accessibilityLabel: "\(item.stars) out of 5 stars from \(item.menteeGivenName)"
                )
            }
            Text("“\(collapsedQuote(item.quote))”")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .italic()
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text(item.context)
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.secondary)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(item.daysAgo)d ago")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppTheme.Colors.cardBorder, lineWidth: 1)
        }
    }

    // MARK: - Profile nudge

    private var profileMotivationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.heart.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.secondary)
                Text("Level up your mentor profile")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }

            VStack(alignment: .leading, spacing: 8) {
                tipRow("Keep your “why I mentor” story fresh—it’s the first thing mentees feel.")
                tipRow("Tight expertise tags help the right mentees find you faster.")
                tipRow("Reply to requests within a day or two when you can; responsiveness builds trust.")
            }

            Button {
                appState.selectedTab = .profile
            } label: {
                Text("Open Profile")
                    .connectInBody()
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .foregroundStyle(.white)
                    .background(AppTheme.Colors.secondary, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.Colors.accent.opacity(0.25), lineWidth: 1)
        }
    }

    private func collapsedQuote(_ raw: String) -> String {
        raw
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.success)
                .padding(.top, 2)
            Text(text)
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        MentorImpactTabView()
            .environmentObject({
                let s = AppState()
                var u = SampleData.currentUser
                u.role = .mentor
                u.fullName = "Diego Morales"
                s.currentUser = u
                s.isLoggedIn = true
                s.hasCompletedOnboarding = true
                return s
            }())
            .environmentObject(SessionsManager(persisted: false))
    }
}
