//
//  SessionTemplatePicker.swift
//  ConnectIn
//

import SwiftUI

/// Browse the full library of session templates and pick one to schedule.
struct SessionTemplatePicker: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    var onPick: (SessionTemplate) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(SessionTemplate.library) { template in
                        Button {
                            onPick(template)
                        } label: {
                            templateCard(template)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle(appState.isMentor ? "Templates for your calls" : "Pick a template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
    }

    private func templateCard(_ template: SessionTemplate) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.accent.opacity(0.18))
                    .frame(width: 46, height: 46)
                Image(systemName: template.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(template.title)
                        .connectInHeadline()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Spacer()
                    Text("\(template.durationMinutes) min")
                        .connectInCaption()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                Text(template.summary)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let firstGoal = template.suggestedGoals.first {
                    HStack(spacing: 6) {
                        Image(systemName: "target")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.accent)
                        Text(firstGoal)
                            .connectInCaption()
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }
                    .padding(.top, 2)
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
}

#Preview {
    SessionTemplatePicker { _ in }
        .environmentObject(AppState())
}
