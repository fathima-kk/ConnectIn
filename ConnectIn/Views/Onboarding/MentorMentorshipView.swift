//
//  MentorMentorshipView.swift
//  ConnectIn
//
//  Mentor onboarding — Step 3 of 3.
//  Mirrors the student "goals" step but on the mentor side: how the mentor
//  wants to help, when they're available, and how many mentees they can
//  realistically take. Built-in boundary settings prevent burnout from day 1.
//

import SwiftUI

struct MentorMentorshipView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isCompleting: Bool = false
    @State private var didSucceed: Bool = false

    private let helpOptions = ProfileViewModel.availableMentorHelp

    /// At least one "ways I help" tag + non-empty availability.
    private var canComplete: Bool {
        !profileVM.goals.isEmpty &&
            !profileVM.availability.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !isCompleting
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                StepProgressBar(currentStep: 3, totalSteps: 3)

                header

                helpSection
                availabilitySection
                capacitySection
                bioSection

                Spacer(minLength: 8)

                actionButtons
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if didSucceed {
                successOverlay
                    .transition(.opacity)
            }
        }
        .sensoryFeedback(.success, trigger: didSucceed)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("How do you mentor?")
                .connectInLargeTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Set boundaries up front so mentorship stays sustainable.")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    /// Multi-select chips for the concrete ways the mentor likes to help.
    /// Stored on `profileVM.goals` so the same model field powers both flows.
    private var helpSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ways I help")
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Pick all that apply.")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)

            TagFlowLayout(horizontalSpacing: 10, verticalSpacing: 10) {
                ForEach(helpOptions, id: \.self) { option in
                    HelpChip(
                        label: option,
                        isSelected: profileVM.goals.contains(option)
                    ) {
                        toggleHelp(option)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.spring(response: 0.35, dampingFraction: 0.78), value: profileVM.goals)
        }
    }

    /// Free-form availability with quick-pick chips. Free-form lets mentors
    /// describe nuance ("Tue/Thu after 7pm PT, async otherwise") that a fixed
    /// schedule picker can't.
    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("When are you available?")
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ProfileViewModel.availabilityPresets, id: \.self) { preset in
                        Button {
                            profileVM.availability = preset
                        } label: {
                            Text(preset)
                                .connectInCaption()
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .foregroundStyle(AppTheme.Colors.primary)
                                .background(Capsule().fill(AppTheme.Colors.accent.opacity(0.15)))
                                .overlay(
                                    Capsule().stroke(AppTheme.Colors.accent.opacity(0.35), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }

            CustomTextField(
                label: "Availability",
                placeholder: "e.g. Tue/Thu evenings (PT)",
                text: $profileVM.availability,
                icon: "calendar"
            )
        }
    }

    /// Hard cap on simultaneous mentees. Acts as the mentor's primary
    /// boundary setting — students see this on the mentor card so they know
    /// when a mentor is at capacity.
    private var capacitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("How many mentees can you take on?")
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                Text("\(profileVM.maxMentees)")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.accent)
                    .monospacedDigit()
            }

            Stepper(
                value: $profileVM.maxMentees,
                in: ProfileViewModel.maxMenteesRange,
                step: 1
            ) {
                Text("Up to \(profileVM.maxMentees) at a time")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .tint(AppTheme.Colors.accent)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(AppTheme.Colors.inputBorder, lineWidth: 1)
            )

            Text("Once you hit your limit, ConnectIn pauses new requests automatically.")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    /// Free-form motivation text, persisted to `profileVM.bio` and rendered as
    /// "Why I mentor" on the mentor's profile.
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why do you want to mentor?")
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            CustomTextEditor(
                label: "About you (optional)",
                text: $profileVM.bio,
                placeholder: "Share what kind of mentor you are and what mentees can expect from you…",
                showsCharacterCount: true
            )
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            PrimaryButton(
                title: "Complete Mentor Profile",
                style: .primary,
                isLoading: isCompleting,
                isDisabled: !canComplete
            ) {
                complete()
            }

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

    private var successOverlay: some View {
        ZStack {
            AppTheme.Colors.background.opacity(0.96).ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.accent.opacity(0.18))
                        .frame(width: 110, height: 110)
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .scaleEffect(didSucceed ? 1 : 0.4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.55), value: didSucceed)
                }
                Text("You're set up to mentor!")
                    .connectInTitle()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Verification email is on the way.")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Actions

    private func toggleHelp(_ option: String) {
        if let idx = profileVM.goals.firstIndex(of: option) {
            profileVM.goals.remove(at: idx)
        } else {
            profileVM.goals.append(option)
        }
    }

    private func complete() {
        guard canComplete else { return }
        isCompleting = true
        Task {
            // Tiny mock delay so the loading indicator is perceptible.
            try? await Task.sleep(for: .seconds(0.8))
            isCompleting = false
            withAnimation(.easeInOut(duration: 0.25)) {
                didSucceed = true
            }
            try? await Task.sleep(for: .seconds(0.9))

            let user = profileVM.makeUser(id: appState.currentUser?.id ?? UUID())
            appState.completeOnboarding(user: user)
        }
    }
}

// MARK: - HelpChip

private struct HelpChip: View {
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
        MentorMentorshipView()
            .environmentObject(AppState())
            .environmentObject({
                let vm = ProfileViewModel()
                vm.role = .mentor
                vm.interests = ["Software Engineering", "Career Switching", "Interview Prep"]
                return vm
            }())
    }
}
