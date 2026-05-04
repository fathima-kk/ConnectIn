//
//  Match.swift
//  ConnectIn
//

import Foundation

enum MatchStatus: String, Codable, CaseIterable, Hashable {
    case pending
    case accepted
    case declined
}

struct Match: Identifiable, Codable, Hashable {
    let id: UUID
    var mentorId: UUID
    var studentId: UUID
    var status: MatchStatus
    var matchedAt: Date
    var compatibilityReasons: [String]
}
