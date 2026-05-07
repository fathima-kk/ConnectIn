//
//  RoleSelectionView.swift
//  ConnectIn
//

import SwiftUI

/// Routes pushed onto the onboarding `NavigationStack`.
///
/// Students and mentors take parallel 3-step flows. We give each its own
/// route values so a single `NavigationStack` can host both without sharing
/// view state across roles.
enum OnboardingRoute: Hashable {
    // Student flow (3 steps)
    case basicInfo(role: UserRole)
    case interests
    case goals

    // Mentor flow (3 steps)
    case mentorBasicInfo
    case mentorExpertise
    case mentorMentorship
}

struct RoleSelectionView: View {
    @State private var selectedRole: UserRole?

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            header

            VStack(spacing: 16) {
                RoleCard(
                    role: .mentee,
                    icon: "person.fill.questionmark",
                    title: "Mentee",
                    description: "Looking for guidance — student, career-switcher, or anywhere in between",
                    isSelected: selectedRole == .mentee
                ) {
                    select(.mentee)
                }

                RoleCard(
                    role: .mentor,
                    icon: "person.badge.shield.checkmark.fill",
                    title: "Mentor",
                    description: "Ready to guide others — free for mentors, always",
                    isSelected: selectedRole == .mentor
                ) {
                    select(.mentor)
                }
            }

            Spacer(minLength: 0)

            continueButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("I am a…")
                .connectInLargeTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Tell us how you'd like to use ConnectIn.")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    private var continueButton: some View {
        Group {
            if let role = selectedRole {
                NavigationLink(value: firstRoute(for: role)) {
                    Text("Continue")
                        .connectInHeadline()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundStyle(AppTheme.Colors.cardBackground)
                        .background(AppTheme.Colors.secondary, in: RoundedRectangle(cornerRadius: 12))
                        .shadow(color: AppTheme.Colors.secondary.opacity(0.35), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            } else {
                Text("Continue")
                    .connectInHeadline()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(AppTheme.Colors.cardBackground)
                    .background(AppTheme.Colors.secondary, in: RoundedRectangle(cornerRadius: 12))
                    .opacity(0.45)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedRole)
    }

    /// First onboarding screen for the chosen role. Centralized so we can't
    /// accidentally drop a mentor into the student flow (or vice-versa).
    private func firstRoute(for role: UserRole) -> OnboardingRoute {
        switch role {
        case .mentee:  return .basicInfo(role: .mentee)
        case .mentor:  return .mentorBasicInfo
        }
    }

    private func select(_ role: UserRole) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            selectedRole = role
        }
    }
}

// MARK: - RoleCard

private struct RoleCard: View {
    let role: UserRole
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? AppTheme.Colors.accent.opacity(0.15)
                              : AppTheme.Colors.background)
                        .frame(width: 64, height: 64)
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(isSelected
                                         ? AppTheme.Colors.accent
                                         : AppTheme.Colors.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .connectInHeadline()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(description)
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected
                                     ? AppTheme.Colors.accent
                                     : AppTheme.Colors.textSecondary.opacity(0.4))
            }
            .padding(20)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .strokeBorder(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.divider,
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .shadow(
                color: isSelected
                    ? AppTheme.Colors.accent.opacity(0.18)
                    : Color.black.opacity(0.04),
                radius: isSelected ? 10 : 4,
                y: isSelected ? 6 : 2
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityLabel("\(title). \(description)")
    }
}

#Preview {
    NavigationStack {
        RoleSelectionView()
    }
}
