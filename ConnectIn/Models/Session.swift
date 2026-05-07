//
//  Session.swift
//  ConnectIn
//

import Foundation

/// A scheduled mentorship meeting between a student and a mentor. Built from a
/// `SessionTemplate` so both sides arrive with a shared agenda and goals.
struct Session: Identifiable, Codable, Hashable {
    enum Status: String, Codable, CaseIterable, Hashable {
        case scheduled
        case completed
        case cancelled
    }

    let id: UUID
    var mentorId: UUID
    var templateId: UUID?
    var title: String
    var date: Date
    /// Length in minutes.
    var duration: Int
    var status: Status
    /// Talking points the pair plans to cover.
    var agenda: [String]
    /// Concrete outcomes both sides committed to before the call.
    var goals: [String]
    var notes: String

    init(
        id: UUID = UUID(),
        mentorId: UUID,
        templateId: UUID? = nil,
        title: String,
        date: Date,
        duration: Int,
        status: Status = .scheduled,
        agenda: [String] = [],
        goals: [String] = [],
        notes: String = ""
    ) {
        self.id = id
        self.mentorId = mentorId
        self.templateId = templateId
        self.title = title
        self.date = date
        self.duration = duration
        self.status = status
        self.agenda = agenda
        self.goals = goals
        self.notes = notes
    }
}
