//
//  ScheduleSessionSheet.swift
//  ConnectIn
//

import SwiftUI

/// Built-in scheduler — pick the connected mentor and a time to drop the
/// chosen template onto the calendar.
struct ScheduleSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var connectionsManager: ConnectionsManager
    @EnvironmentObject private var sessionsManager: SessionsManager

    let template: SessionTemplate

    @State private var selectedMentorID: UUID?
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var didSchedule: Bool = false

    private var availableMentors: [Mentor] {
        let acceptedIds = Set(connectionsManager.acceptedConnections.map { $0.mentorId })
        let mentors = SampleData.mentors.filter { acceptedIds.contains($0.id) }
        // Fall back to all mentors if nothing accepted yet — keeps demo useful.
        return mentors.isEmpty ? SampleData.mentors : mentors
    }

    private var selectedMentor: Mentor? {
        guard let id = selectedMentorID else { return availableMentors.first }
        return availableMentors.first { $0.id == id }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    summaryCard
                    mentorPicker
                    datePicker
                    agendaPreview
                }
                .padding(20)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Schedule session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Schedule") { schedule() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.secondary)
                        .disabled(selectedMentor == nil)
                }
            }
            .onAppear {
                if selectedMentorID == nil {
                    selectedMentorID = availableMentors.first?.id
                }
            }
            .sensoryFeedback(.success, trigger: didSchedule)
        }
    }

    private var summaryCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.accent.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: template.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(template.title)
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("\(template.durationMinutes) min • \(template.agenda.count) agenda items")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(template.summary)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    private var mentorPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("With which mentor?")
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            VStack(spacing: 8) {
                ForEach(availableMentors) { mentor in
                    Button {
                        selectedMentorID = mentor.id
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(AppTheme.Colors.accent.opacity(0.25))
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Text(initials(mentor.user.fullName))
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(AppTheme.Colors.primary)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mentor.user.fullName)
                                    .connectInBody()
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppTheme.Colors.textPrimary)
                                Text("\(mentor.jobTitle) @ \(mentor.company)")
                                    .connectInCaption()
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                            Spacer()
                            if selectedMentorID == mentor.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.Colors.secondary)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMentorID == mentor.id
                                      ? AppTheme.Colors.accent.opacity(0.14)
                                      : AppTheme.Colors.cardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMentorID == mentor.id
                                        ? AppTheme.Colors.secondary
                                        : AppTheme.Colors.cardBorder,
                                        lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("When?")
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            DatePicker(
                "Date and time",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .tint(AppTheme.Colors.secondary)
            .padding(12)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
            )
        }
    }

    private var agendaPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Agenda preview")
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            ForEach(Array(template.agenda.enumerated()), id: \.offset) { idx, item in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(idx + 1).")
                        .connectInBody()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.secondary)
                    Text(item)
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
        )
    }

    private func schedule() {
        guard let mentor = selectedMentor else { return }
        sessionsManager.schedule(template: template, with: mentor, on: selectedDate)
        didSchedule = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { dismiss() }
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first.map(String.init) }.joined()
    }
}

#Preview {
    ScheduleSessionSheet(template: SessionTemplate.library[0])
        .environmentObject(ConnectionsManager())
        .environmentObject(SessionsManager())
}
