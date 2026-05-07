//
//  SessionsManager.swift
//  ConnectIn
//

import Combine
import Foundation

/// Tracks scheduled sessions and milestone achievements. Backed by
/// `UserDefaults` so the demo can show meaningful "X days connected" history.
@MainActor
final class SessionsManager: ObservableObject {
    private static let defaults = UserDefaults.standard
    private enum Keys {
        static let sessions = "ConnectIn.sessions"
        static let milestones = "ConnectIn.milestones"
    }

    @Published private(set) var sessions: [Session] = []
    @Published private(set) var milestones: [Milestone] = []

    // MARK: - Init

    init(persisted: Bool = true) {
        if persisted, let saved = Self.loadSessions() {
            sessions = saved
        } else {
            sessions = SampleData.seedSessions
            persistSessions()
        }

        if persisted, let saved = Self.loadMilestones() {
            milestones = saved
        } else {
            milestones = SampleData.seedMilestones
            persistMilestones()
        }
    }

    // MARK: - Computed views

    var upcomingSessions: [Session] {
        sessions
            .filter { $0.status == .scheduled && $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }

    var pastSessions: [Session] {
        sessions
            .filter { $0.status == .completed || $0.date < Date() }
            .sorted { $0.date > $1.date }
    }

    var nextSession: Session? {
        upcomingSessions.first
    }

    /// Total minutes of completed mentorship time.
    var totalMinutesMentored: Int {
        sessions.filter { $0.status == .completed }.reduce(0) { $0 + $1.duration }
    }

    var completedSessionCount: Int {
        sessions.filter { $0.status == .completed }.count
    }

    var milestoneCount: Int { milestones.count }

    // MARK: - Mutations

    func schedule(template: SessionTemplate, with mentor: Mentor, on date: Date) {
        let session = Session(
            mentorId: mentor.id,
            templateId: template.id,
            title: template.title,
            date: date,
            duration: template.durationMinutes,
            status: .scheduled,
            agenda: template.agenda,
            goals: template.suggestedGoals
        )
        sessions.append(session)
        persistSessions()
    }

    func complete(_ session: Session, notes: String = "") {
        guard let idx = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[idx].status = .completed
        if !notes.isEmpty {
            sessions[idx].notes = notes
        }
        persistSessions()

        addMilestone(
            Milestone(
                title: "Completed \"\(sessions[idx].title)\"",
                detail: "\(sessions[idx].duration) minutes of focused mentorship.",
                category: .session
            )
        )
    }

    func cancel(_ session: Session) {
        guard let idx = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[idx].status = .cancelled
        persistSessions()
    }

    func toggleGoal(_ goal: String, on session: Session) {
        guard let idx = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        if let g = sessions[idx].goals.firstIndex(of: goal) {
            sessions[idx].goals.remove(at: g)
        }
        persistSessions()
    }

    func addMilestone(_ milestone: Milestone) {
        milestones.insert(milestone, at: 0)
        persistMilestones()
    }

    func reset() {
        sessions = SampleData.seedSessions
        milestones = SampleData.seedMilestones
        persistSessions()
        persistMilestones()
    }

    // MARK: - Persistence

    private func persistSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            Self.defaults.set(data, forKey: Keys.sessions)
        }
    }

    private func persistMilestones() {
        if let data = try? JSONEncoder().encode(milestones) {
            Self.defaults.set(data, forKey: Keys.milestones)
        }
    }

    private static func loadSessions() -> [Session]? {
        guard let data = defaults.data(forKey: Keys.sessions) else { return nil }
        return try? JSONDecoder().decode([Session].self, from: data)
    }

    private static func loadMilestones() -> [Milestone]? {
        guard let data = defaults.data(forKey: Keys.milestones) else { return nil }
        return try? JSONDecoder().decode([Milestone].self, from: data)
    }
}
