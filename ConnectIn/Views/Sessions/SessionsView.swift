//
//  SessionsView.swift
//  ConnectIn
//

import SwiftUI

/// 4th-tab home for structured mentorship: upcoming sessions, past sessions,
/// session templates (so no one stares at a blank page), and milestone
/// progress so both sides can see impact over time.
struct SessionsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var connectionsManager: ConnectionsManager
    @EnvironmentObject private var sessionsManager: SessionsManager

    @State private var path = NavigationPath()
    @State private var schedulingTemplate: SessionTemplate?
    @State private var browseTemplates: Bool = false
    @State private var showingPaywall: Bool = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    progressCard
                    nextSessionCard
                    templatesShortlist
                    pastSessionsSection
                    milestonesSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Sessions")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Session.self) { session in
                SessionDetailView(session: session)
            }
            .sheet(isPresented: $browseTemplates) {
                SessionTemplatePicker { template in
                    browseTemplates = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        // `hasPremiumAccess` is always true for mentors, so
                        // they can schedule freely without seeing the paywall.
                        if appState.hasPremiumAccess {
                            schedulingTemplate = template
                        } else {
                            showingPaywall = true
                        }
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $schedulingTemplate) { template in
                ScheduleSessionSheet(template: template)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Structured mentorship")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.secondary)
                .fontWeight(.semibold)
            Text("Show up prepared")
                .connectInTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Templates set the agenda. Goals keep you moving. Both sides can see the impact.")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }

    // MARK: - Progress dashboard card

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Your impact", systemImage: "chart.line.uptrend.xyaxis")
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.primary)
                Spacer()
                membershipPill
            }

            HStack(spacing: 12) {
                statTile(
                    title: "Sessions",
                    value: "\(sessionsManager.completedSessionCount)",
                    icon: "video.fill"
                )
                statTile(
                    title: "Minutes",
                    value: "\(sessionsManager.totalMinutesMentored)",
                    icon: "clock.fill"
                )
                statTile(
                    title: "Milestones",
                    value: "\(sessionsManager.milestoneCount)",
                    icon: "flag.checkered"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.Colors.accent.opacity(0.4), lineWidth: 1)
        )
    }

    /// Label + background color for the membership pill, derived from the
    /// current subscription status. Pulled out so the view body stays a clean
    /// single `Button` and Swift's view builder doesn't have to reason about
    /// imperative `let` assignments inside a switch.
    private struct MembershipPillStyle {
        let label: String
        let background: Color
    }

    private var membershipPillStyle: MembershipPillStyle {
        switch appState.subscription.status {
        case .none:
            return MembershipPillStyle(label: "Try Pro", background: AppTheme.Colors.accent)
        case .trialing:
            let days = appState.subscription.daysUntilRenewal ?? 0
            return MembershipPillStyle(label: "Trial · \(days)d", background: AppTheme.Colors.accent)
        case .active:
            return MembershipPillStyle(label: "Pro", background: AppTheme.Colors.success)
        case .expired:
            return MembershipPillStyle(label: "Renew", background: AppTheme.Colors.error)
        }
    }

    /// Mentors see a permanent "Free" pill (no paywall to open). Mentees
    /// see the dynamic subscription pill that opens the paywall.
    @ViewBuilder
    private var membershipPill: some View {
        if appState.isMentor {
            Text("Free")
                .connectInCaption()
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(AppTheme.Colors.success))
        } else {
            let style = membershipPillStyle
            Button {
                showingPaywall = true
            } label: {
                Text(style.label)
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(style.background))
            }
            .buttonStyle(.plain)
        }
    }

    private func statTile(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.accent)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            Text(title)
                .connectInCaption()
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.10))
        )
    }

    // MARK: - Next session card

    @ViewBuilder
    private var nextSessionCard: some View {
        if let next = sessionsManager.nextSession,
           let mentor = mentor(for: next) {
            Button {
                path.append(next)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Up Next", systemImage: "calendar")
                            .connectInCaption()
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.secondary)
                        Spacer()
                        Text(relativeDate(next.date))
                            .connectInCaption()
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    Text(next.title)
                        .connectInHeadline()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text("with \(mentor.user.fullName) • \(next.duration) min")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    if let firstGoal = next.goals.first {
                        HStack(spacing: 6) {
                            Image(systemName: "target")
                                .font(.system(size: 11))
                                .foregroundStyle(AppTheme.Colors.accent)
                            Text(firstGoal)
                                .connectInCaption()
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        } else {
            VStack(spacing: 10) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 32))
                    .foregroundStyle(AppTheme.Colors.secondary)
                Text("No sessions scheduled")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Pick a template below to set a clear agenda before your next call.")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Templates

    private var templatesShortlist: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Session templates")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                Button {
                    browseTemplates = true
                } label: {
                    Text("See all")
                        .connectInCaption()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.secondary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SessionTemplate.library.prefix(4)) { template in
                        Button {
                            if appState.hasPremiumAccess {
                                schedulingTemplate = template
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            templateCard(template)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func templateCard(_ template: SessionTemplate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: template.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.secondary)
            }
            Text(template.title)
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("\(template.durationMinutes) min")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(14)
        .frame(width: 160, alignment: .leading)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Past sessions

    @ViewBuilder
    private var pastSessionsSection: some View {
        if !sessionsManager.pastSessions.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Past sessions")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                ForEach(sessionsManager.pastSessions) { session in
                    Button {
                        path.append(session)
                    } label: {
                        pastSessionRow(session)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func pastSessionRow(_ session: Session) -> some View {
        let mentor = mentor(for: session)
        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.Colors.accent.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(session.title)
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("\(mentor?.user.fullName ?? "Mentor") • \(formattedDate(session.date))")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(12)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Milestones

    @ViewBuilder
    private var milestonesSection: some View {
        if !sessionsManager.milestones.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Milestones")
                        .connectInHeadline()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Spacer()
                    Text("\(sessionsManager.milestoneCount) unlocked")
                        .connectInCaption()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                ForEach(sessionsManager.milestones) { milestone in
                    milestoneRow(milestone)
                }
            }
        }
    }

    private func milestoneRow(_ milestone: Milestone) -> some View {
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
            Text(formattedDate(milestone.achievedAt))
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(12)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func mentor(for session: Session) -> Mentor? {
        SampleData.mentors.first { $0.id == session.mentorId }
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

#Preview {
    SessionsView()
        .environmentObject(AppState())
        .environmentObject(ConnectionsManager())
        .environmentObject(SessionsManager())
}
