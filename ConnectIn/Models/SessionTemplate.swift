//
//  SessionTemplate.swift
//  ConnectIn
//

import Foundation

/// A pre-built playbook that students and mentors can drop onto a calendar in
/// one tap. Solves "blank page anxiety" before sessions.
struct SessionTemplate: Identifiable, Hashable {
    let id: UUID
    let title: String
    let icon: String
    let summary: String
    let durationMinutes: Int
    /// Talking points the pair will work through together.
    let agenda: [String]
    /// Concrete outcomes recommended for this kind of session.
    let suggestedGoals: [String]

    static let library: [SessionTemplate] = [
        SessionTemplate(
            id: UUID(uuidString: "30000000-0000-4000-8000-000000000001")!,
            title: "First Meeting",
            icon: "hand.wave.fill",
            summary: "Get to know each other and align on what mentorship looks like.",
            durationMinutes: 30,
            agenda: [
                "Backgrounds and what brought you here",
                "Communication preferences and cadence",
                "Top 1-2 things you want to leave with",
                "Set expectations + next session"
            ],
            suggestedGoals: [
                "Agree on cadence (e.g. biweekly)",
                "Pick a focus area for the next 30 days"
            ]
        ),
        SessionTemplate(
            id: UUID(uuidString: "30000000-0000-4000-8000-000000000002")!,
            title: "Career Pivot",
            icon: "arrow.triangle.swap",
            summary: "Map a thoughtful path to your next role or industry.",
            durationMinutes: 45,
            agenda: [
                "Current situation + what's not working",
                "Options on the table and gut reactions",
                "Skills + signals you'll need to add",
                "30/60/90-day plan"
            ],
            suggestedGoals: [
                "Pick one role to optimize for next quarter",
                "List 3 skill gaps + how you'll close them"
            ]
        ),
        SessionTemplate(
            id: UUID(uuidString: "30000000-0000-4000-8000-000000000003")!,
            title: "Resume Review",
            icon: "doc.text.fill",
            summary: "Tighten your resume for a specific role.",
            durationMinutes: 30,
            agenda: [
                "Walk through current resume top-to-bottom",
                "Reframe bullets to highlight impact",
                "Tailor for the target role",
                "Decide what to cut + what to keep"
            ],
            suggestedGoals: [
                "Rewrite top 5 bullets with metrics",
                "Submit revised draft within a week"
            ]
        ),
        SessionTemplate(
            id: UUID(uuidString: "30000000-0000-4000-8000-000000000004")!,
            title: "Mock Interview",
            icon: "mic.fill",
            summary: "Practice realistic interview questions with structured feedback.",
            durationMinutes: 45,
            agenda: [
                "Warm-up: tell me about yourself",
                "2-3 behavioral questions (STAR format)",
                "1 role-specific deep-dive",
                "Live feedback + next reps"
            ],
            suggestedGoals: [
                "Identify 2 patterns to work on",
                "Schedule a follow-up mock within 2 weeks"
            ]
        ),
        SessionTemplate(
            id: UUID(uuidString: "30000000-0000-4000-8000-000000000005")!,
            title: "Goal Check-In",
            icon: "target",
            summary: "Review progress, celebrate wins, and reset what's next.",
            durationMinutes: 30,
            agenda: [
                "Wins since last session",
                "Blockers + what's slowing you down",
                "Reset focus for the next two weeks",
                "Commit to one bold action"
            ],
            suggestedGoals: [
                "Mark 1 goal complete or refine it",
                "Identify the next bold move"
            ]
        ),
        SessionTemplate(
            id: UUID(uuidString: "30000000-0000-4000-8000-000000000006")!,
            title: "Networking Strategy",
            icon: "person.3.sequence.fill",
            summary: "Build a sustainable habit of reaching out without it feeling icky.",
            durationMinutes: 30,
            agenda: [
                "Current network audit",
                "Identify 5 high-leverage people to reach out to",
                "Draft authentic outreach messages",
                "Set a weekly outreach quota"
            ],
            suggestedGoals: [
                "Send 3 outreach messages this week",
                "Schedule 1 informational coffee chat"
            ]
        )
    ]
}
