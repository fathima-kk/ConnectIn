//
//  SessionDetailView.swift
//  ConnectIn
//

import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var sessionsManager: SessionsManager

    let session: Session

    @State private var notes: String = ""
    @State private var didComplete: Bool = false

    private var mentor: Mentor? {
        SampleData.mentors.first { $0.id == session.mentorId }
    }

    private var liveSession: Session {
        sessionsManager.sessions.first { $0.id == session.id } ?? session
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                detailsCard
                agendaSection
                goalsSection
                notesSection
                actionButtons
            }
            .padding(20)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { notes = liveSession.notes }
        .sensoryFeedback(.success, trigger: didComplete)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                statusPill
                Spacer()
            }
            Text(liveSession.title)
                .connectInTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            if let mentor {
                Text("with \(mentor.user.fullName) • \(mentor.jobTitle) @ \(mentor.company)")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }

    private var statusPill: some View {
        let (label, color): (String, Color) = {
            switch liveSession.status {
            case .scheduled: return ("Scheduled", AppTheme.Colors.secondary)
            case .completed: return ("Completed", AppTheme.Colors.success)
            case .cancelled: return ("Cancelled", AppTheme.Colors.error)
            }
        }()
        return Text(label)
            .connectInCaption()
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            row(icon: "calendar", text: formattedDate(liveSession.date))
            row(icon: "clock", text: "\(liveSession.duration) minutes")
            row(icon: "video", text: "Video call")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    private func row(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.secondary)
                .frame(width: 18)
            Text(text)
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
    }

    @ViewBuilder
    private var agendaSection: some View {
        if !liveSession.agenda.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Agenda")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                ForEach(Array(liveSession.agenda.enumerated()), id: \.offset) { idx, item in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(idx + 1).")
                            .connectInBody()
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.secondary)
                        Text(item)
                            .connectInBody()
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }
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
    }

    @ViewBuilder
    private var goalsSection: some View {
        if !liveSession.goals.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Shared goals")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                ForEach(liveSession.goals, id: \.self) { goal in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "target")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.accent)
                        Text(goal)
                            .connectInBody()
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }
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
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .connectInHeadline()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            TextEditor(text: $notes)
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .padding(10)
                .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if liveSession.status == .scheduled {
            VStack(spacing: 10) {
                PrimaryButton(title: "Mark as Completed", style: .primary) {
                    sessionsManager.complete(liveSession, notes: notes)
                    didComplete = true
                }
                Button {
                    sessionsManager.cancel(liveSession)
                } label: {
                    Text("Cancel session")
                        .connectInBody()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .short
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: SampleData.seedSessions[0])
            .environmentObject(SessionsManager())
    }
}
