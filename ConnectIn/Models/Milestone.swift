//
//  Milestone.swift
//  ConnectIn
//

import Foundation

/// A unit of progress visible to both mentor and student. Powers the impact
/// dashboard and makes growth tangible over time.
struct Milestone: Identifiable, Codable, Hashable {
    enum Category: String, Codable, CaseIterable, Hashable {
        case session
        case goal
        case application
        case skill

        var icon: String {
            switch self {
            case .session: return "video.fill"
            case .goal: return "target"
            case .application: return "doc.badge.plus"
            case .skill: return "star.fill"
            }
        }

        var label: String {
            switch self {
            case .session: return "Session"
            case .goal: return "Goal"
            case .application: return "Application"
            case .skill: return "Skill"
            }
        }
    }

    let id: UUID
    let title: String
    let detail: String
    let category: Category
    let achievedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        detail: String = "",
        category: Category,
        achievedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.category = category
        self.achievedAt = achievedAt
    }
}
