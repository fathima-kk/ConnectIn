//
//  ProfileViewModel.swift
//  ConnectIn
//

import Combine
import Foundation
import SwiftUI

/// Captures user input across the 3-step onboarding profile flow for BOTH
/// students and mentors. Lives for the lifetime of the onboarding
/// `NavigationStack` and is passed between steps via `@EnvironmentObject`.
///
/// The view model intentionally holds fields for both roles. The student flow
/// fills `university`/`major`/etc. and leaves mentor fields default; the
/// mentor flow does the inverse. `makeUser()` knows how to assemble the right
/// `User` from whichever set was filled.
@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Shared

    @Published var role: UserRole = .mentee
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var profileImageURL: String? = nil

    /// Used for both flows. For mentors this becomes their "Why I mentor" copy.
    @Published var bio: String = ""

    /// Multi-select tags. For students: interests; for mentors: expertise areas.
    @Published var interests: [String] = []

    /// Multi-select tags. For students: career goals; for mentors: ways they
    /// help (e.g. "Resume reviews", "Mock interviews").
    @Published var goals: [String] = []

    // MARK: - Student-only

    @Published var university: String = ""
    @Published var major: String = ""
    @Published var graduationYear: Int = Calendar.current.component(.year, from: Date()) + 1
    @Published var isFirstGen: Bool = false
    /// Toggle on the mentee step 1: only when ON do we show the
    /// graduation-year picker and first-gen options. Lets non-students breeze
    /// past student-coded fields they don't care about.
    @Published var isCurrentStudent: Bool = true

    // MARK: - Mentor-only

    @Published var jobTitle: String = ""
    @Published var company: String = ""
    @Published var yearsExperience: Int = 3
    @Published var availability: String = ""
    @Published var maxMentees: Int = 3

    // MARK: - Picker option lists

    /// Tags students pick from on step 2.
    static let availableInterests: [String] = [
        "Software Engineering",
        "Product Management",
        "UX/UI Design",
        "Data Science",
        "Marketing",
        "Startups",
        "Career Switching",
        "Networking",
        "Internships",
        "Interview Prep",
        "Resume Reviews",
        "Leadership",
        "Public Speaking",
        "Open Source",
        "Mentorship",
        "Research"
    ]

    /// Tags mentors pick from on step 2 — broader and more career-stage-aware
    /// than the student list above.
    static let availableExpertise: [String] = [
        "Software Engineering",
        "Backend",
        "Frontend",
        "Mobile Development",
        "Machine Learning",
        "Data Science",
        "Product Management",
        "Product Strategy",
        "UX Research",
        "UI Design",
        "Engineering Management",
        "Tech Lead",
        "Startup Founding",
        "Growth Marketing",
        "Sales",
        "Operations",
        "Finance",
        "Career Switching",
        "Interview Prep",
        "Resume Reviews"
    ]

    /// Tags mentors pick on step 3 — the concrete ways they help.
    static let availableMentorHelp: [String] = [
        "Career planning",
        "Resume reviews",
        "Mock interviews",
        "Skill development",
        "Networking strategy",
        "Salary negotiation",
        "First-job prep",
        "Career switching",
        "Imposter syndrome",
        "Work-life balance",
        "Leadership coaching",
        "Portfolio reviews"
    ]

    /// Common availability blurbs shown as quick-pick chips during onboarding.
    static let availabilityPresets: [String] = [
        "Weeknight evenings (PT)",
        "Weekend mornings (PT)",
        "Tue/Thu 6–8pm ET",
        "Async-only / messaging",
        "Biweekly 30-min video"
    ]

    static let graduationYearRange: ClosedRange<Int> = 2024...2030
    static let yearsExperienceRange: ClosedRange<Int> = 1...30
    static let maxMenteesRange: ClosedRange<Int> = 1...8

    // MARK: - Build the User

    /// Assemble a `User` value from the collected fields.
    ///
    /// For students we leave mentor fields nil; for mentors we leave the
    /// student-only fields at their empty defaults (still a valid `User`).
    func makeUser(id: UUID = UUID()) -> User {
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)

        switch role {
        case .mentee:
            // Sentinel-zero graduationYear means "not a current student" — we
            // hide the "Class of" row in ProfileView in that case.
            let storedGradYear = isCurrentStudent ? graduationYear : 0
            let storedFirstGen = isCurrentStudent ? isFirstGen : false

            return User(
                id: id,
                email: email,
                fullName: trimmedName,
                role: .mentee,
                profileImageURL: profileImageURL,
                bio: trimmedBio,
                interests: interests,
                goals: goals,
                university: university.trimmingCharacters(in: .whitespacesAndNewlines),
                major: major.trimmingCharacters(in: .whitespacesAndNewlines),
                graduationYear: storedGradYear,
                isFirstGen: storedFirstGen,
                jobTitle: nil,
                company: nil,
                yearsExperience: nil,
                availability: nil,
                maxMentees: nil,
                createdAt: Date()
            )

        case .mentor:
            return User(
                id: id,
                email: email,
                fullName: trimmedName,
                role: .mentor,
                profileImageURL: profileImageURL,
                bio: trimmedBio,
                interests: interests,                // expertise areas
                goals: goals,                        // ways they help
                university: "",
                major: "",
                graduationYear: 0,
                isFirstGen: false,
                jobTitle: jobTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                company: company.trimmingCharacters(in: .whitespacesAndNewlines),
                yearsExperience: yearsExperience,
                availability: availability.trimmingCharacters(in: .whitespacesAndNewlines),
                maxMentees: maxMentees,
                createdAt: Date()
            )
        }
    }

    /// Pre-populate from the placeholder user created at sign-up so users see
    /// what they typed earlier when they jump back to a step.
    func seed(from user: User?) {
        guard let user else { return }
        if fullName.isEmpty { fullName = user.fullName }
        if email.isEmpty { email = user.email }
        if interests.isEmpty { interests = user.interests }
        if goals.isEmpty { goals = user.goals }
        if bio.isEmpty { bio = user.bio }

        // Student fields
        if university.isEmpty { university = user.university }
        if major.isEmpty { major = user.major }
        isFirstGen = isFirstGen || user.isFirstGen

        // Mentor fields
        if jobTitle.isEmpty, let s = user.jobTitle { jobTitle = s }
        if company.isEmpty, let s = user.company { company = s }
        if let years = user.yearsExperience { yearsExperience = years }
        if availability.isEmpty, let s = user.availability { availability = s }
        if let cap = user.maxMentees { maxMentees = cap }
    }
}
