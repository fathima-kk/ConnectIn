//
//  ProfileInterestsView.swift
//  ConnectIn
//
//  Step 2 of 3 — pick interests for matching.
//

import SwiftUI

struct ProfileInterestsView: View {
    @EnvironmentObject private var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    private let options = ProfileViewModel.availableInterests

    private var canContinue: Bool {
        profileVM.interests.count >= 2
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                StepProgressBar(currentStep: 2, totalSteps: 3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("What are you into?")
                        .connectInLargeTitle()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text("Pick at least 2 — we'll use them to surface relevant mentors.")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                interestGrid

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

    private var interestGrid: some View {
        TagFlowLayout(horizontalSpacing: 10, verticalSpacing: 10) {
            ForEach(options, id: \.self) { interest in
                InterestChip(
                    label: interest,
                    isSelected: profileVM.interests.contains(interest)
                ) {
                    toggle(interest)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(response: 0.35, dampingFraction: 0.78), value: profileVM.interests)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            NavigationLink(value: OnboardingRoute.goals) {
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

    private func toggle(_ interest: String) {
        if let idx = profileVM.interests.firstIndex(of: interest) {
            profileVM.interests.remove(at: idx)
        } else {
            profileVM.interests.append(interest)
        }
    }
}

// MARK: - InterestChip

private struct InterestChip: View {
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
        ProfileInterestsView()
            .environmentObject(ProfileViewModel())
    }
}
