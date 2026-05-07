//
//  MentorExpertiseView.swift
//  ConnectIn
//
//  Mentor onboarding — Step 2 of 3.
//  Mirrors the student "interests" step but asks for areas of expertise so
//  mentors get matched with students who actually want to learn from them.
//

import SwiftUI

struct MentorExpertiseView: View {
    @EnvironmentObject private var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    private let options = ProfileViewModel.availableExpertise

    /// Mentors must pick at least 3 expertise tags so matching has signal.
    private var canContinue: Bool {
        profileVM.interests.count >= 3
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                StepProgressBar(currentStep: 2, totalSteps: 3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("What can you help with?")
                        .connectInLargeTitle()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text("Pick at least 3 — mentees will see these as your expertise tags.")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                expertiseGrid

                Spacer(minLength: 8)

                actionButtons
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private var expertiseGrid: some View {
        TagFlowLayout(horizontalSpacing: 10, verticalSpacing: 10) {
            ForEach(options, id: \.self) { area in
                ExpertiseChip(
                    label: area,
                    isSelected: profileVM.interests.contains(area)
                ) {
                    toggle(area)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(response: 0.35, dampingFraction: 0.78), value: profileVM.interests)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            NavigationLink(value: OnboardingRoute.mentorMentorship) {
                Text("Continue")
                    .connectInHeadline()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(AppTheme.Colors.cardBackground)
                    .background(AppTheme.Colors.secondary, in: RoundedRectangle(cornerRadius: 12))
                    .shadow(color: AppTheme.Colors.secondary.opacity(0.35), radius: 8, y: 4)
                    .opacity(canContinue ? 1 : 0.45)
            }
            .buttonStyle(.plain)
            .disabled(!canContinue)

            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
    }

    private func toggle(_ area: String) {
        if let idx = profileVM.interests.firstIndex(of: area) {
            profileVM.interests.remove(at: idx)
        } else {
            profileVM.interests.append(area)
        }
    }
}

// MARK: - ExpertiseChip
//
// Visually identical to the student `InterestChip` so the design language
// stays consistent. Pulled into its own private type so we don't import the
// student version and accidentally pull in student-specific behavior later.

private struct ExpertiseChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .transition(.scale.combined(with: .opacity))
                }
                Text(label)
                    .connectInCaption()
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? AppTheme.Colors.cardBackground : AppTheme.Colors.textPrimary)
            .background(
                Capsule().fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.cardBackground)
            )
            .overlay {
                Capsule()
                    .strokeBorder(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.inputBorder,
                        lineWidth: 1
                    )
            }
            .scaleEffect(isSelected ? 1.04 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
    }
}

#Preview {
    NavigationStack {
        MentorExpertiseView()
            .environmentObject({
                let vm = ProfileViewModel()
                vm.role = .mentor
                return vm
            }())
    }
}
