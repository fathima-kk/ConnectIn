//
//  User.swift
//  ConnectIn
//

import Foundation

enum UserRole: String, Codable, CaseIterable, Hashable {
    case student
    case mentor
}

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    var email: String
    var fullName: String
    var role: UserRole
    var profileImageURL: String?
    var bio: String
    var interests: [String]
    var goals: [String]
    var university: String
    var major: String
    var graduationYear: Int
    var isFirstGen: Bool
    var createdAt: Date
}
