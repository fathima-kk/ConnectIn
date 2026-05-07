//
//  MentorDashboardView.swift
//  ConnectIn
//
//  Home tab when the user logs in as a mentor. Mirrors the structure of the
//  mentee dashboard (banner → primary section → progress → suggestions) but
//  with mentor-shaped content: pending requests, active mentees, impact
//  stats, and a "free for mentors" badge instead of a subscription banner.
//

import SwiftUI

struct MentorDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var sessionsManager: SessionsManager

    /// Pending and active mentee mock data. Drawn from `SampleData` so the
    /// demo always has something to render — in a real build this would come
    /// from the network.
    @State private var pending: [DemoMenteeRequest] = SampleData.demoMenteeRequests
    @State private var active: [DemoActiveMentee] = SampleData.demoActiveMentees
    @State private var lastDecision: DecisionToast?

    private var user: User {
        appState.currentUser ?? SampleData.currentUser
    }

    private var greetingName: String {
        user.fullName.split(separator: " ").first.map(String.init) ?? user.fullName
    }

    /// Hours given = (sum of session minutes) / 60, rounded.
    private var hoursMentored: Int {
        Int((Double(sessionsManager.totalMinutesMentored) / 60.0).rounded())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                greetingHeader
                freeForMentorsBanner
                impactCard
                requestsSection
                activeMenteesSection
                recentActivitySection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .overlay(alignment: .top) {
            if let toast = lastDecision {
                decisionToastView(toast)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome back, \(greetingName)!")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Here's what's happening in your mentorship today.")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(.top, 4)
    }

    // MARK: - Free-for-mentors banner

    /// Stand-in for the subscription banner mentees see. Mentors are the
    /// supply side of the marketplace, so we keep them on the platform for
    /// free — and we celebrate it.
    private var freeForMentorsBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .padding(10)
                .background(.white.opacity(0.18), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Free forever for mentors")
                    .connectInBody()
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("Track your impact, set boundaries, and keep mentorship sustainable — no fees, ever.")
                    .connectInCaption()
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Impact card

    /// Replaces the mentee progress card. Shows the mentor's track record
    /// across all mentees they've worked with.
    private var impactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Your impact", systemImage: "chart.line.uptrend.xyaxis")
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.secondary)
                Spacer()
            }

            HStack(spacing: 10) {
                impactTile(
                    icon: "person.3.fill",
                    label: "Active",
                    value: "\(active.count)"
                )
                impactTile(
                    icon: "video.fill",
                    label: "Sessions",
                    value: "\(sessionsManager.completedSessionCount)"
                )
                impactTile(
                    icon: "clock.fill",
                    label: "Hours given",
                    value: "\(hoursMentored)"
                )
                impactTile(
                    icon: "flag.checkered",
                    label: "Wins",
                    value: "\(sessionsManager.milestoneCount)"
                )
            }
        }
    }

    private func impactTile(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.secondary)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(label)
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Pending requests

    private var requestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("Mentee Requests")
                Spacer()
                if !pending.isEmpty {
                    Text("\(pending.count) waiting")
                        .connectInCaption()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }

            if pending.isEmpty {
                emptyRequestsCard
            } else {
                VStack(spacing: 12) {
                    ForEach(pending) { request in
                        requestCard(request)
                    }
                }
            }
        }
    }

    private func requestCard(_ request: DemoMenteeRequest) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                avatar(name: request.name)
                VStack(alignment: .leading, spacing: 2) {
                    Text(request.name)
                        .connectInHeadline()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(request.affiliation)
                        .connectInCaption()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                Spacer()
                Text("\(request.sentDaysAgo)d ago")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            Text("\u{201C}\(request.askLine)\u{201D}")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button {
                    decline(request)
                } label: {
                    Text("Decline")
                        .connectInBody()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(AppTheme.Colors.background, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(AppTheme.Colors.divider, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    accept(request)
                } label: {
                    Text("Accept")
                        .connectInBody()
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(AppTheme.Colors.secondary, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    private var emptyRequestsCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "envelope.open")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.Colors.secondary)
            Text("All caught up")
                .connectInHeadline()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("New mentee requests will show up here.")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Active mentees

    private var activeMenteesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Active Mentees")
            if active.isEmpty {
                Text("No active mentees yet — accept a request above to get started.")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
                    )
            } else {
                VStack(spacing: 10) {
                    ForEach(active) { mentee in
                        activeMenteeRow(mentee)
                    }
                }
            }
        }
    }

    private func activeMenteeRow(_ mentee: DemoActiveMentee) -> some View {
        HStack(alignment: .top, spacing: 12) {
            avatar(name: mentee.name)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(mentee.name)
                        .connectInHeadline()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Spacer()
                    Text("\(mentee.sessionsHeld) sessions")
                        .connectInCaption()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.secondary)
                }
                Text(mentee.affiliation)
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(mentee.lastNote)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .padding(.top, 2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Connected \(mentee.connectedSinceDaysAgo) day\(mentee.connectedSinceDaysAgo == 1 ? "" : "s") ago")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Recent activity

    /// Surfaces the most recently unlocked milestones — your mentees' wins,
    /// effectively. Reuses the same `SessionsManager` data that powers the
    /// mentee progress dashboard, just framed differently.
    @ViewBuilder
    private var recentActivitySection: some View {
        if !sessionsManager.milestones.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Recent Wins")
                VStack(spacing: 10) {
                    ForEach(sessionsManager.milestones.prefix(3)) { milestone in
                        recentRow(milestone)
                    }
                }
                Button {
                    appState.selectedTab = .sessions
                } label: {
                    Text("Open Sessions")
                        .connectInCaption()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func recentRow(_ milestone: Milestone) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.Colors.accent.opacity(0.20))
                    .frame(width: 38, height: 38)
                Image(systemName: milestone.category.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                if !milestone.detail.isEmpty {
                    Text(milestone.detail)
                        .connectInCaption()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .textCase(.uppercase)
            .tracking(0.6)
    }

    /// Initials-based avatar so we don't need real photos for demo mentees.
    private func avatar(name: String) -> some View {
        let initials = name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
        return ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.Colors.secondary, AppTheme.Colors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 42, height: 42)
            Text(initials.uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Actions

    private func accept(_ request: DemoMenteeRequest) {
        withAnimation(.easeInOut(duration: 0.25)) {
            pending.removeAll { $0.id == request.id }
            active.append(
                DemoActiveMentee(
                    id: request.id,
                    name: request.name,
                    affiliation: request.affiliation,
                    connectedSinceDaysAgo: 0,
                    sessionsHeld: 0,
                    lastNote: "Just connected — schedule a first session."
                )
            )
            lastDecision = DecisionToast(
                message: "Accepted \(request.name)",
                tint: AppTheme.Colors.success
            )
        }
        clearToastShortly()
    }

    private func decline(_ request: DemoMenteeRequest) {
        withAnimation(.easeInOut(duration: 0.25)) {
            pending.removeAll { $0.id == request.id }
            lastDecision = DecisionToast(
                message: "Declined \(request.name)",
                tint: AppTheme.Colors.error
            )
        }
        clearToastShortly()
    }

    private func clearToastShortly() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeInOut(duration: 0.25)) {
                lastDecision = nil
            }
        }
    }

    private func decisionToastView(_ toast: DecisionToast) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(toast.tint, in: Circle())
            Text(toast.message)
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.cardBackground, in: Capsule())
        .overlay(Capsule().stroke(AppTheme.Colors.cardBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }

    private struct DecisionToast: Equatable {
        let message: String
        let tint: Color
    }
}

#Preview {
    NavigationStack {
        MentorDashboardView()
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
            .environmentObject(SessionsManager())
    }
}
