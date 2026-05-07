//
//  ConnectionsManager.swift
//  ConnectIn
//

import Combine
import Foundation

/// Tracks every outgoing/incoming connection state. Backed by `UserDefaults`
/// so demo state survives app restarts.
@MainActor
final class ConnectionsManager: ObservableObject {
    private static let defaults = UserDefaults.standard
    private enum Keys {
        static let connections = "ConnectIn.connections"
        static let sentRequests = "ConnectIn.sentRequests"
    }

    // MARK: - Types

    struct SentRequest: Hashable, Codable {
        let mentorId: UUID
        let message: String
        let sentAt: Date
    }

    // MARK: - Published state

    @Published private(set) var matches: [UUID: Match] = [:]
    @Published private(set) var sentRequests: [UUID: SentRequest] = [:]

    // MARK: - Computed bucket views

    var pendingConnections: [Match] {
        matches.values.filter { $0.status == .pending }
    }

    var acceptedConnections: [Match] {
        matches.values.filter { $0.status == .accepted }
    }

    var declinedConnections: [Match] {
        matches.values.filter { $0.status == .declined }
    }

    var pendingCount: Int { pendingConnections.count }
    var acceptedCount: Int { acceptedConnections.count }

    // MARK: - Init

    init(seed: [Match]? = nil, persisted: Bool = true) {
        if persisted, let saved = Self.loadMatches() {
            matches = saved
        } else {
            let initial = seed ?? SampleData.matches
            for match in initial {
                matches[match.mentorId] = match
            }
            persistMatches()
        }

        if persisted, let savedRequests = Self.loadSentRequests() {
            sentRequests = savedRequests
        }
    }

    // MARK: - Queries

    func status(for mentor: Mentor) -> MatchStatus? {
        matches[mentor.id]?.status
    }

    func getConnectionStatus(mentorId: UUID) -> MatchStatus? {
        matches[mentorId]?.status
    }

    func hasPendingRequest(for mentor: Mentor) -> Bool {
        matches[mentor.id]?.status == .pending
    }

    func isConnected(with mentor: Mentor) -> Bool {
        matches[mentor.id]?.status == .accepted
    }

    func match(for mentor: Mentor) -> Match? {
        matches[mentor.id]
    }

    /// Returns the single mentor the student is currently connected with, if any.
    func getActiveMentor() -> Mentor? {
        SampleData.mentors.first { matches[$0.id]?.status == .accepted }
    }

    /// Returns the most-recent mentor with a pending outgoing request.
    func getPendingMentor() -> Mentor? {
        SampleData.mentors.first { matches[$0.id]?.status == .pending }
    }

    // MARK: - Actions

    /// Mocks a 1-second async API call before storing the new request.
    func sendRequest(to mentor: Mentor, message: String) async {
        try? await Task.sleep(for: .seconds(1))
        requestConnection(mentorId: mentor.id, message: message)
    }

    /// Synchronous variant — useful from tests / demo seeding.
    func requestConnection(mentorId: UUID, message: String?) {
        let trimmed = (message ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let reasons = Array(SampleData.compatibilityPhrases.shuffled().prefix(3))
        let match = Match(
            id: UUID(),
            mentorId: mentorId,
            studentId: SampleData.currentUser.id,
            status: .pending,
            matchedAt: Date(),
            compatibilityReasons: reasons
        )
        matches[mentorId] = match
        sentRequests[mentorId] = SentRequest(
            mentorId: mentorId,
            message: trimmed,
            sentAt: Date()
        )
        persistMatches()
        persistSentRequests()
    }

    func acceptConnection(matchId: UUID) {
        guard let key = matches.first(where: { $0.value.id == matchId })?.key else { return }
        matches[key]?.status = .accepted
        persistMatches()
    }

    func declineConnection(matchId: UUID) {
        guard let key = matches.first(where: { $0.value.id == matchId })?.key else { return }
        matches[key]?.status = .declined
        persistMatches()
    }

    /// Wipe stored state and re-seed from `SampleData`.
    func reset() {
        matches.removeAll()
        sentRequests.removeAll()
        for match in SampleData.matches {
            matches[match.mentorId] = match
        }
        persistMatches()
        persistSentRequests()
    }

    // MARK: - Persistence helpers

    private func persistMatches() {
        let stringKeyed = Dictionary(uniqueKeysWithValues:
            matches.map { ($0.key.uuidString, $0.value) }
        )
        if let data = try? JSONEncoder().encode(stringKeyed) {
            Self.defaults.set(data, forKey: Keys.connections)
        }
    }

    private func persistSentRequests() {
        let stringKeyed = Dictionary(uniqueKeysWithValues:
            sentRequests.map { ($0.key.uuidString, $0.value) }
        )
        if let data = try? JSONEncoder().encode(stringKeyed) {
            Self.defaults.set(data, forKey: Keys.sentRequests)
        }
    }

    private static func loadMatches() -> [UUID: Match]? {
        guard let data = defaults.data(forKey: Keys.connections),
              let stringKeyed = try? JSONDecoder().decode([String: Match].self, from: data) else {
            return nil
        }
        return Dictionary(uniqueKeysWithValues: stringKeyed.compactMap { (key, value) in
            guard let uuid = UUID(uuidString: key) else { return nil }
            return (uuid, value)
        })
    }

    private static func loadSentRequests() -> [UUID: SentRequest]? {
        guard let data = defaults.data(forKey: Keys.sentRequests),
              let stringKeyed = try? JSONDecoder().decode([String: SentRequest].self, from: data) else {
            return nil
        }
        return Dictionary(uniqueKeysWithValues: stringKeyed.compactMap { (key, value) in
            guard let uuid = UUID(uuidString: key) else { return nil }
            return (uuid, value)
        })
    }
}
