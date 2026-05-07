//
//  ProfileHeader.swift
//  ConnectIn
//

import SwiftUI

struct ProfileHeader: View {
    var imageURL: String?
    let name: String
    let role: UserRole
    var subtitle: String?
    var isEditable: Bool = false
    var onEditTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                avatar
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(AppTheme.Colors.cardBackground, lineWidth: 3)
                    }

                if isEditable, let onEditTap {
                    Button(action: onEditTap) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.Colors.cardBackground)
                            .padding(8)
                            .background(AppTheme.Colors.secondary, in: Circle())
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                    .offset(x: 4, y: 4)
                }
            }

            Text(name)
                .connectInTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            roleBadge

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacing)
    }

    @ViewBuilder
    private var avatar: some View {
        if let urlString = imageURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderAvatar
                default:
                    placeholderAvatar
                        .overlay { ProgressView() }
                }
            }
        } else {
            placeholderAvatar
        }
    }

    private var placeholderAvatar: some View {
        Image(systemName: "person.fill")
            .font(.system(size: 44))
            .foregroundStyle(AppTheme.Colors.cardBackground.opacity(0.9))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.secondary, AppTheme.Colors.accent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var roleBadge: some View {
        let isMentee = role == .mentee
        return Text(isMentee ? "Mentee" : "Mentor")
            .connectInCaption()
            .fontWeight(.semibold)
            .foregroundStyle(isMentee ? AppTheme.Colors.primary : AppTheme.Colors.cardBackground)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                isMentee
                    ? AppTheme.Colors.primary.opacity(0.12)
                    : AppTheme.Colors.secondary,
                in: Capsule()
            )
    }
}

#Preview("Mentee") {
    ProfileHeader(
        imageURL: nil,
        name: "Sofia Martinez",
        role: .mentee,
        subtitle: "San Francisco State University",
        isEditable: true,
        onEditTap: {}
    )
    .background(AppTheme.Colors.background)
}

#Preview("Mentor") {
    ProfileHeader(
        imageURL: nil,
        name: "Priya Shah",
        role: .mentor,
        subtitle: "Product Manager @ Figma",
        isEditable: false,
        onEditTap: nil
    )
    .background(AppTheme.Colors.background)
}
