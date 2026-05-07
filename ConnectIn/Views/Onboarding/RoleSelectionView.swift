//
//  RoleSelectionView.swift
//  ConnectIn
//

import SwiftUI

struct RoleSelectionView: View {
    let onContinue: (UserRole) -> Void

    @State private var selectedRole: UserRole?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("I am a...")
                .connectInTitle()
                .foregroundStyle(AppTheme.Colors.primary)
                .padding(.top, 16)

            VStack(spacing: 16) {
                roleCard(
                    role: .student,
                    icon: "graduationcap.fill",
                    title: "Student",
                    subtitle: "Looking for guidance and mentorship"
                )

                roleCard(
                    role: .mentor,
                    icon: "person.badge.shield.checkmark.fill",
                    title: "Mentor",
                    subtitle: "Ready to guide and inspire"
                )
            }

            Spacer(minLength: 16)

            PrimaryButton(
                title: "Continue",
                style: .primary,
                isLoading: false,
                isDisabled: selectedRole == nil
            ) {
                guard let selectedRole else { return }
                onContinue(selectedRole)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func roleCard(role: UserRole, icon: String, title: String, subtitle: String) -> some View {
        let isSelected = selectedRole == role

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedRole = role
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.primary)

                Text(title)
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text(subtitle)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? AppTheme.Colors.accent : Color(hex: "#D1D5DB"),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            }
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.03), radius: isSelected ? 12 : 6, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        RoleSelectionView { _ in }
    }
}
