//
//  ProfileGoalsView.swift
//  ConnectIn
//
//  Step 3 of 3 — choose goals + optional bio.
//

import SwiftUI

struct ProfileGoalsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isCompleting: Bool = false
    @State private var didSucceed: Bool = false

    /// Broad set of mentee goals. Works for current students looking for
    /// internships, recent grads chasing first roles, or career-switchers.
    private let goalOptions: [GoalOption] = [
        GoalOption(title: "Land my first role", icon: "briefcase.fill"),
        GoalOption(title: "Build my professional network", icon: "person.3.fill"),
        GoalOption(title: "Get career advice", icon: "bubble.left.and.bubble.right.fill"),
        GoalOption(title: "Learn new skills", icon: "book.fill"),
        GoalOption(title: "Switch careers or industries", icon: "arrow.triangle.swap"),
        GoalOption(title: "Find work-life balance", icon: "heart.fill")
    ]

    private var canComplete: Bool {
        !profileVM.goals.isEmpty && !isCompleting
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                StepProgressBar(currentStep: 3, totalSteps: 3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("What are your goals?")
                        .connectInLargeTitle()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text("Help us match you with the right mentors.")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                Text("Pick up to 3")
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.background, in: Capsule())
                    .overlay { Capsule().strokeBorder(AppTheme.Colors.divider, lineWidth: 1) }

                goalGrid

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

    private var goalGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(goalOptions) { option in
                GoalCard(
                    option: option,
                    isSelected: profileVM.goals.contains(option.title)
                ) {
                    toggle(option)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.78), value: profileVM.goals)
    }

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Anything else you'd like to share?")
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            CustomTextEditor(
                label: "About you (optional)",
                text: $profileVM.bio,
                placeholder: "Tell mentors about your background, what you're working on, or what you hope to learn…",
                showsCharacterCount: true
            )
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            PrimaryButton(
                title: "Complete Profile",
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
                        .fill(AppTheme.Colors.success.opacity(0.18))
                        .frame(width: 110, height: 110)
                    Image(systemName: "checkmark")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.success)
                        .scaleEffect(didSucceed ? 1 : 0.4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.55), value: didSucceed)
                }
                Text("Profile complete!")
                    .connectInTitle()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Bringing you to your dashboard…")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Actions

    private func toggle(_ option: GoalOption) {
        if let idx = profileVM.goals.firstIndex(of: option.title) {
            profileVM.goals.remove(at: idx)
        } else if profileVM.goals.count < 3 {
            profileVM.goals.append(option.title)
        }
    }

    private func complete() {
        guard canComplete else { return }
        isCompleting = true
        Task {
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

// MARK: - GoalOption

struct GoalOption: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
}

private struct GoalCard: View {
    let option: GoalOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: option.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? AppTheme.Colors.cardBackground : AppTheme.Colors.accent)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.accent.opacity(0.15))
                    )

                Text(option.title)
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? AppTheme.Colors.cardBackground : AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.cardBackground)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.cardBackground)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .strokeBorder(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.divider,
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .shadow(
                color: isSelected ? AppTheme.Colors.accent.opacity(0.25) : .black.opacity(0.04),
                radius: isSelected ? 10 : 4,
                y: isSelected ? 6 : 2
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    NavigationStack {
        ProfileGoalsView()
            .environmentObject(AppState())
            .environmentObject(ProfileViewModel())
    }
}
