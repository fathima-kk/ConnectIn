//
//  Mentor.swift
//  ConnectIn
//

import Foundation

struct Mentor: Identifiable, Codable, Hashable {
    let id: UUID
    var user: User
    var jobTitle: String
    var company: String
    var yearsExperience: Int
    var expertise: [String]
    var availability: String
    var maxMentees: Int
    var currentMentees: Int
    /// Display score from matching (mock data sets this explicitly).
    var matchPercentage: Int
}
