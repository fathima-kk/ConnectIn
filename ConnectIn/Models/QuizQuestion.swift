//
//  QuizQuestion.swift
//  ConnectIn
//

import Foundation

/// One step of the compatibility quiz that powers per-mentor match scores.
struct QuizQuestion: Identifiable, Hashable {
    enum Dimension: String, CaseIterable, Codable, Hashable {
        case industry
        case goals
        case personality
        case communication
        case stage
    }

    let id: UUID
    let dimension: Dimension
    let prompt: String
    let options: [String]

    static let library: [QuizQuestion] = [
        QuizQuestion(
            id: UUID(uuidString: "40000000-0000-4000-8000-000000000001")!,
            dimension: .industry,
            prompt: "Which industry are you most curious about?",
            options: ["Tech / Software", "Product Management", "Design", "Data & Analytics", "Marketing"]
        ),
        QuizQuestion(
            id: UUID(uuidString: "40000000-0000-4000-8000-000000000002")!,
            dimension: .goals,
            prompt: "What's your top goal in the next 6 months?",
            options: [
                "Land my first internship",
                "Switch career paths",
                "Build a network in tech",
                "Sharpen specific skills",
                "Get promoted"
            ]
        ),
        QuizQuestion(
            id: UUID(uuidString: "40000000-0000-4000-8000-000000000003")!,
            dimension: .personality,
            prompt: "Which describes how you like to work?",
            options: ["Very analytical", "Big-picture thinker", "People-first", "Hands-on builder", "Creative explorer"]
        ),
        QuizQuestion(
            id: UUID(uuidString: "40000000-0000-4000-8000-000000000004")!,
            dimension: .communication,
            prompt: "How do you prefer to keep in touch with a mentor?",
            options: ["Video calls", "Voice notes", "Async messaging", "In-person", "Mix of everything"]
        ),
        QuizQuestion(
            id: UUID(uuidString: "40000000-0000-4000-8000-000000000005")!,
            dimension: .stage,
            prompt: "Where are you in your journey?",
            options: ["Just exploring", "Targeting first role", "Switching paths", "Mid-career", "Levelling up"]
        )
    ]
}

/// Snapshot of the quiz answers used to recompute match scores.
struct QuizResult: Codable, Hashable {
    var answers: [QuizQuestion.Dimension: String]
    var completedAt: Date

    var isComplete: Bool {
        QuizQuestion.Dimension.allCases.allSatisfy { answers[$0] != nil }
    }
}
