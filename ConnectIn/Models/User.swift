//
//  User.swift
//  ConnectIn
//

import Foundation

/// Two roles in the marketplace.
///
/// We rename "student" → "mentee" because ConnectIn now serves anyone looking
/// for mentorship (career-changers, early-career folks, returning learners),
/// not just university students. The rawValue stays `"student"` so existing
/// `UserDefaults`-persisted profiles still decode without a migration.
enum UserRole: String, Codable, CaseIterable, Hashable {
    case mentee = "student"
    case mentor
}

/// One unified user record for both sides of the marketplace. Student-only and
/// mentor-only fields are optional so each onboarding flow only fills what it
/// needs. This keeps profile lookups, persistence, and view bindings simple
/// without forcing a separate `MentorUser` type.
struct User: Identifiable, Codable, Hashable {
    let id: UUID
    var email: String
    var fullName: String
    var role: UserRole
    var profileImageURL: String?

    /// Free-form description shown on the profile screen. Used as
    /// "About me" for students and "Why I mentor" for mentors.
    var bio: String

    /// Tags. For students: areas of curiosity. For mentors: areas of expertise.
    var interests: [String]

    /// Tags. For students: career goals. For mentors: ways they help.
    var goals: [String]

    // MARK: - Student fields (unused for mentors, default to empty/zero)

    var university: String
    var major: String
    var graduationYear: Int
    var isFirstGen: Bool

    // MARK: - Mentor fields (nil for students)
    //
    // Optional so adding/removing mentor data never invalidates a student
    // record — and the JSON we serialize stays small for student profiles.
    //
    // Each defaults to `nil` at the declaration site so the synthesized
    // memberwise initializer accepts call sites that only fill student data.

    var jobTitle: String? = nil
    var company: String? = nil
    var yearsExperience: Int? = nil
    /// Free-form availability description, e.g. "Tue/Thu evenings (PT)".
    var availability: String? = nil
    /// Cap on simultaneously active mentees the mentor wants to take on.
    var maxMentees: Int? = nil

    var createdAt: Date
}
