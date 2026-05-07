//
//  DashboardView.swift
//  ConnectIn
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var connectionsManager: ConnectionsManager
    @EnvironmentObject private var sessionsManager: SessionsManager

    @State private var showingPaywall: Bool = false

    private var user: User {
        appState.currentUser ?? SampleData.currentUser
    }

    private var greetingName: String {
        user.fullName.split(separator: " ").first.map(String.init) ?? user.fullName
    }

    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Hope your morning is off to a great start."
        case 12..<17: return "Make the most of your afternoon."
        case 17..<22: return "Wind down and reflect on your wins today."
        default: return "Burning the midnight oil — we got you."
        }
    }

    private var connectedMentor: Mentor? {
        connectionsManager.getActiveMentor()
    }

    private var pendingMentor: Mentor? {
        connectionsManager.getPendingMentor()
    }

    private var suggestedMentors: [Mentor] {
        SampleData.mentors
            .filter { connectionsManager.status(for: $0) == nil || connectionsManager.status(for: $0) == .declined }
            .sorted { $0.matchPercentage > $1.matchPercentage }
            .prefix(4)
            .map { $0 }
    }

    /// Routes to a role-specific dashboard. Mentees see the mentor-discovery
    /// flavor (this view's body); mentors get a different experience entirely
    /// in `MentorDashboardView`. Splitting at the top keeps each side's
    /// layout simple instead of branching every section.
    var body: some View {
        Group {
            if appState.isMentor {
                MentorDashboardView()
            } else {
                menteeBody
            }
        }
    }

    /// Original mentee-flavored dashboard. Untouched aside from being lifted
    /// out of `body` so the mentor branch can take over.
    private var menteeBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                greetingHeader
                subscriptionBanner
                yourMentorSection
                progressSnapshotSection
                quickStatsSection
                suggestedMentorsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Subscription banner

    private var subscriptionBanner: some View {
        Button {
            showingPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: appState.subscription.hasAccess ? "checkmark.seal.fill" : "sparkles")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.white.opacity(0.18), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(subscriptionHeadline)
                        .connectInBody()
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text(subscriptionSubtitle)
                        .connectInCaption()
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))
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
        .buttonStyle(.plain)
    }

    private var subscriptionHeadline: String {
        switch appState.subscription.status {
        case .none:
            return "Try \(Subscription.planName) free for \(Subscription.trialDays) days"
        case .trialing:
            let days = appState.subscription.daysUntilRenewal ?? 0
            return "\(Subscription.planName) trial · \(days) day\(days == 1 ? "" : "s") left"
        case .active:
            return "\(Subscription.planName) member"
        case .expired:
            return "Renew \(Subscription.planName)"
        }
    }

    private var subscriptionSubtitle: String {
        switch appState.subscription.status {
        case .none:
            return "Verified mentors, structured sessions, milestone tracking — $\(String(format: "%.2f", Subscription.monthlyPrice))/mo after."
        case .trialing:
            return "Tap to manage or upgrade — billing starts at $\(String(format: "%.2f", Subscription.monthlyPrice))/mo."
        case .active:
            return "$\(String(format: "%.2f", Subscription.monthlyPrice))/mo · all Pro features unlocked."
        case .expired:
            return "Pick up where you left off for $\(String(format: "%.2f", Subscription.monthlyPrice))/mo."
        }
    }

    // MARK: - Progress snapshot

    private var progressSnapshotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("Your Progress")
                Spacer()
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

            HStack(spacing: 10) {
                progressTile(
                    icon: "video.fill",
                    label: "Sessions",
                    value: "\(sessionsManager.completedSessionCount)"
                )
                progressTile(
                    icon: "flag.checkered",
                    label: "Milestones",
                    value: "\(sessionsManager.milestoneCount)"
                )
                progressTile(
                    icon: "clock.fill",
                    label: "Minutes",
                    value: "\(sessionsManager.totalMinutesMentored)"
                )
            }
        }
    }

    private func progressTile(icon: String, label: String, value: String) -> some View {
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hello, \(greetingName)! 👋")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(timeOfDayGreeting)
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(.top, 4)
    }

    // MARK: - Your Mentor

    private var yourMentorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Your Mentor")

            if let mentor = connectedMentor {
                ConnectedMentorCard(mentor: mentor)
            } else if let mentor = pendingMentor {
                PendingMentorCard(mentor: mentor)
            } else {
                emptyMentorCard
            }
        }
    }

    private var emptyMentorCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 64, height: 64)
                .background(AppTheme.Colors.accent.opacity(0.12), in: Circle())

            VStack(spacing: 4) {
                Text("No mentors yet")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Browse the community and find someone who's been where you want to go.")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                appState.selectedTab = .browse
            } label: {
                Text("Find a Mentor")
                    .connectInHeadline()
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .foregroundStyle(.white)
                    .background(AppTheme.Colors.accent, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.Colors.divider, lineWidth: 1)
        }
    }

    // MARK: - Quick stats

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Quick Stats")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StatCard(
                        icon: "calendar",
                        title: "Days Connected",
                        value: "\(daysConnected)",
                        tint: AppTheme.Colors.secondary
                    )
                    StatCard(
                        icon: "checkmark.seal.fill",
                        title: "Goals Completed",
                        value: "\(goalsCompleted)/\(user.goals.count)",
                        tint: AppTheme.Colors.success
                    )
                    StatCard(
                        icon: "video.fill",
                        title: "Next Session",
                        value: nextSessionLabel,
                        tint: AppTheme.Colors.accent
                    )
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var daysConnected: Int {
        guard connectedMentor != nil,
              let match = SampleData.matches.first(where: { $0.status == .accepted }) else {
            return 0
        }
        return max(1, Calendar.current.dateComponents([.day], from: match.matchedAt, to: Date()).day ?? 0)
    }

    private var goalsCompleted: Int {
        min(user.goals.count, max(0, user.goals.count - 1))
    }

    private var nextSessionLabel: String {
        guard let next = sessionsManager.nextSession else {
            return "Not scheduled"
        }
        let f = DateFormatter()
        f.dateFormat = "EEE, h:mma"
        return f.string(from: next.date)
    }

    // MARK: - Suggested mentors

    private var suggestedMentorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("You Might Also Like")
                Spacer()
                Button {
                    appState.selectedTab = .browse
                } label: {
                    Text("See All")
                        .connectInCaption()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.accent)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(suggestedMentors) { mentor in
                        NavigationLink(value: mentor) {
                            CompactMentorCard(mentor: mentor)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .textCase(.uppercase)
            .tracking(0.6)
    }
}

// MARK: - Connected mentor card

private struct ConnectedMentorCard: View {
    let mentor: Mentor

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                MentorAvatarBubble(mentor: mentor, size: 54)
                VStack(alignment: .leading, spacing: 4) {
                    Text(mentor.user.fullName)
                        .connectInHeadline()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text("\(mentor.jobTitle) @ \(mentor.company)")
                        .connectInCaption()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                Spacer()
                StatusPill(text: "Connected", color: AppTheme.Colors.success)
            }

            HStack(spacing: 10) {
                actionButton(icon: "message.fill", title: "Message")
                actionButton(icon: "calendar.badge.plus", title: "Schedule")
            }
        }
        .padding(16)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.Colors.success.opacity(0.4), lineWidth: 1)
        }
        .shadow(color: AppTheme.Colors.success.opacity(0.12), radius: 12, y: 4)
    }

    private func actionButton(icon: String, title: String) -> some View {
        Button {} label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .connectInBody()
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .foregroundStyle(AppTheme.Colors.accent)
            .background(AppTheme.Colors.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pending mentor card

private struct PendingMentorCard: View {
    let mentor: Mentor

    var body: some View {
        HStack(spacing: 14) {
            MentorAvatarBubble(mentor: mentor, size: 54)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("Connection Pending")
                        .connectInBody()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    StatusPill(text: "Pending", color: AppTheme.Colors.accent)
                }
                Text(mentor.user.fullName)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Waiting for response…")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.Colors.accent.opacity(0.4), lineWidth: 1)
        }
    }
}

// MARK: - Compact mentor card

private struct CompactMentorCard: View {
    let mentor: Mentor

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                MentorAvatarBubble(mentor: mentor, size: 44)
                Spacer(minLength: 0)
                Text("\(mentor.matchPercentage)%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.accent, in: Capsule())
            }
            Text(mentor.user.fullName)
                .font(.system(size: 16, weight: .semibold))
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
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.Colors.cardBorder, lineWidth: 1)
        }
    }
}

// MARK: - Stat card

private struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 160, alignment: .leading)
        .padding(16)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppTheme.Colors.cardBorder, lineWidth: 1)
        }
    }
}

// MARK: - Helper bubbles

private struct MentorAvatarBubble: View {
    let mentor: Mentor
    let size: CGFloat

    var body: some View {
        Group {
            if let s = mentor.user.profileImageURL, let url = URL(string: s) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Image(systemName: "person.fill")
            .font(.system(size: size * 0.45))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.secondary, AppTheme.Colors.accent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

private struct StatusPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .connectInCaption()
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.14), in: Capsule())
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(AppState())
            .environmentObject(ConnectionsManager())
            .environmentObject(SessionsManager())
    }
}
