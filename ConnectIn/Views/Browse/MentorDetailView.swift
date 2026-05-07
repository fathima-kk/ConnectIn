//
//  MentorDetailView.swift
//  ConnectIn
//

import SwiftUI

struct MentorDetailView: View {
    let mentor: Mentor

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var connectionsManager: ConnectionsManager

    @State private var showingRequestSheet: Bool = false
    @State private var showingPaywall: Bool = false
    @State private var toast: Toast?

    private var connectionStatus: MatchStatus? {
        connectionsManager.status(for: mentor)
    }

    private var roleLine: String {
        "\(mentor.jobTitle) @ \(mentor.company)"
    }

    private var compatibilityReasons: [String] {
        if let match = connectionsManager.match(for: mentor) {
            return match.compatibilityReasons
        }
        return Array(SampleData.compatibilityPhrases.shuffled().prefix(3))
    }

    /// Mock deep link used by the share sheet.
    private var shareURL: URL {
        URL(string: "https://connectin.app/mentor/\(mentor.id.uuidString)")
            ?? URL(string: "https://connectin.app")!
    }

    private var shareMessage: String {
        "Check out \(mentor.user.fullName) on ConnectIn! They're a \(mentor.jobTitle) at \(mentor.company)."
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    hero
                    whyWeMatchedSection
                    aboutSection
                    expertiseSection
                    detailsSection
                    educationSection
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background.ignoresSafeArea())

            stickyFooter
        }
        .navigationTitle("Mentor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: shareURL,
                    subject: Text("\(mentor.user.fullName) on ConnectIn"),
                    message: Text(shareMessage)
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
        }
        .toast($toast)
        .sheet(isPresented: $showingRequestSheet) {
            ConnectionRequestSheet(mentor: mentor) { sentName in
                toast = Toast(message: "Request sent to \(sentName)!", style: .success)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .environmentObject(connectionsManager)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 14) {
            avatar
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(AppTheme.Colors.cardBackground, lineWidth: 4)
                }
                .shadow(color: .black.opacity(0.12), radius: 14, y: 8)

            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text(mentor.user.fullName)
                        .connectInTitle()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    if mentor.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.accent)
                            .accessibilityLabel("Verified mentor")
                    }
                }
                Text(roleLine)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            HStack(spacing: 8) {
                matchBadge
                if mentor.isVerified {
                    verifiedPill
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var avatar: some View {
        if let urlString = mentor.user.profileImageURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    placeholderAvatar
                }
            }
        } else {
            placeholderAvatar
        }
    }

    private var placeholderAvatar: some View {
        Image(systemName: "person.fill")
            .font(.system(size: 56))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.secondary, AppTheme.Colors.accent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var matchBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .bold))
            Text("\(mentor.matchPercentage)% Match")
                .connectInCaption()
                .fontWeight(.bold)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .foregroundStyle(.white)
        .background(
            Capsule().fill(
                LinearGradient(
                    colors: [AppTheme.Colors.accent, AppTheme.Colors.secondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        )
        .shadow(color: AppTheme.Colors.accent.opacity(0.35), radius: 8, y: 4)
    }

    private var verifiedPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12, weight: .bold))
            Text("Verified")
                .connectInCaption()
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(AppTheme.Colors.primary)
        .background(
            Capsule().fill(AppTheme.Colors.accent.opacity(0.18))
        )
        .overlay(
            Capsule().stroke(AppTheme.Colors.accent.opacity(0.45), lineWidth: 1)
        )
    }

    // MARK: - Sections

    private var whyWeMatchedSection: some View {
        DetailSection(title: "Why We Matched") {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 4)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(compatibilityReasons, id: \.self) { reason in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.Colors.accent)
                            Text(reason)
                                .connectInBody()
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
            }
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
        }
    }

    private var aboutSection: some View {
        DetailSection(title: "About") {
            Text(mentor.user.bio)
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }

    private var expertiseSection: some View {
        DetailSection(title: "Expertise") {
            TagFlowView(tags: mentor.expertise, color: .teal)
                .padding(14)
                .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }

    private var detailsSection: some View {
        DetailSection(title: "Details") {
            VStack(spacing: 0) {
                detailRow(icon: "briefcase.fill", label: "Experience", value: "\(mentor.yearsExperience) years")
                Divider().padding(.leading, 48)
                detailRow(
                    icon: "person.2.fill",
                    label: "Mentees",
                    value: "\(mentor.currentMentees) of \(mentor.maxMentees)"
                )
                Divider().padding(.leading, 48)
                detailRow(icon: "clock.fill", label: "Availability", value: mentor.availability)
            }
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }

    private var educationSection: some View {
        DetailSection(title: "Education") {
            VStack(spacing: 0) {
                detailRow(icon: "building.columns.fill", label: "University", value: mentor.user.university)
                Divider().padding(.leading, 48)
                detailRow(
                    icon: "graduationcap.fill",
                    label: "Class of",
                    value: String(mentor.user.graduationYear)
                )
            }
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 32, height: 32)
                .background(AppTheme.Colors.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            Text(label)
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .connectInBody()
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // MARK: - Sticky footer

    private var stickyFooter: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.4)
            requestButton
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
        }
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var requestButton: some View {
        switch connectionStatus {
        case .accepted:
            disabledFooterButton(label: "Connected", icon: "checkmark.circle.fill", tint: AppTheme.Colors.success)
        case .pending:
            disabledFooterButton(label: "Request Sent", icon: "checkmark", tint: AppTheme.Colors.secondary)
        case .declined, .none:
            // `hasPremiumAccess` returns true for mentors automatically, so
            // a mentor browsing the catalog (e.g. for inspiration) wouldn't
            // hit the paywall.
            if appState.hasPremiumAccess {
                PrimaryButton(title: "Request Connection", style: .primary, isLoading: false) {
                    showingRequestSheet = true
                }
            } else {
                PrimaryButton(
                    title: "Unlock with Pro · $\(String(format: "%.2f", Subscription.monthlyPrice))/mo",
                    style: .primary,
                    isLoading: false
                ) {
                    showingPaywall = true
                }
            }
        }
    }

    private func disabledFooterButton(label: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(label)
                .connectInHeadline()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .foregroundStyle(.white)
        .background(tint, in: RoundedRectangle(cornerRadius: 12))
        .opacity(0.85)
    }
}

// MARK: - DetailSection

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.6)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Connection request sheet

struct ConnectionRequestSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var connectionsManager: ConnectionsManager

    let mentor: Mentor
    let onSent: (String) -> Void

    @State private var message: String = ""
    @State private var isSending: Bool = false

    private static let maxLength: Int = 200

    private var canSend: Bool {
        message.count <= Self.maxLength && !isSending
    }

    private var firstName: String {
        mentor.user.fullName.split(separator: " ").first.map(String.init) ?? mentor.user.fullName
    }

    /// Pre-built openers — solves the blank-page anxiety students often hit
    /// when sending a first message.
    private var templates: [(label: String, body: String)] {
        [
            ("Quick intro",
             "Hi \(firstName), I'm exploring \(mentor.jobTitle.lowercased()) work and would love to learn how you got started — and what you wish you'd known."),
            ("Coffee chat",
             "Hey \(firstName)! Would you be open to a 30-minute chat about life as a \(mentor.jobTitle.lowercased()) at \(mentor.company)? I'm trying to figure out where to focus."),
            ("Resume review",
             "Hi \(firstName), I'm preparing for my next round of applications and would value your eye on my resume — totally understand if the timing's off."),
            ("Specific question",
             "Hi \(firstName) — I have one focused question about breaking into \(mentor.expertise.first ?? "your space"). Would 15 minutes work?")
        ]
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                miniHeader

                templatesPicker

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Include a message (optional)")
                            .connectInBody()
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Spacer()
                        Text("\(message.count)/\(Self.maxLength)")
                            .connectInCaption()
                            .foregroundStyle(message.count > Self.maxLength
                                             ? AppTheme.Colors.error
                                             : AppTheme.Colors.textSecondary)
                            .monospacedDigit()
                    }

                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Hi \(mentor.user.fullName.split(separator: " ").first.map(String.init) ?? mentor.user.fullName) — I'd love to learn from your experience…")
                                .connectInBody()
                                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.7))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $message)
                            .connectInBody()
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .frame(minHeight: 140)
                    }
                    .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                message.count > Self.maxLength
                                    ? AppTheme.Colors.error
                                    : AppTheme.Colors.inputBorder,
                                lineWidth: 1
                            )
                    }
                }

                Spacer(minLength: 8)

                PrimaryButton(
                    title: "Send Request",
                    style: .primary,
                    isLoading: isSending,
                    isDisabled: !canSend
                ) {
                    send()
                }

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .connectInBody()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .disabled(isSending)
            }
            .padding(20)
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Send Connection Request")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sensoryFeedback(.success, trigger: isSending == false ? nil : isSending)
    }

    private var templatesPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.secondary)
                Text("Start from a template")
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(templates, id: \.label) { template in
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                message = template.body
                            }
                        } label: {
                            Text(template.label)
                                .connectInCaption()
                                .fontWeight(.semibold)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .foregroundStyle(AppTheme.Colors.primary)
                                .background(
                                    Capsule().fill(AppTheme.Colors.accent.opacity(0.15))
                                )
                                .overlay(
                                    Capsule().stroke(AppTheme.Colors.accent.opacity(0.35), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var miniHeader: some View {
        HStack(spacing: 12) {
            placeholderAvatar
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(mentor.user.fullName)
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("\(mentor.jobTitle) @ \(mentor.company)")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(12)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(AppTheme.Colors.divider, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var placeholderAvatar: some View {
        if let s = mentor.user.profileImageURL, let url = URL(string: s) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    fallback
                }
            }
        } else {
            fallback
        }
    }

    private var fallback: some View {
        Image(systemName: "person.fill")
            .font(.system(size: 22))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.secondary, AppTheme.Colors.accent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private func send() {
        guard canSend else { return }
        isSending = true
        Task {
            await connectionsManager.sendRequest(to: mentor, message: message)
            isSending = false
            let firstName = mentor.user.fullName.split(separator: " ").first.map(String.init) ?? mentor.user.fullName
            dismiss()
            onSent(firstName)
        }
    }
}

#Preview {
    NavigationStack {
        MentorDetailView(mentor: SampleData.mentors[3])
            .environmentObject(ConnectionsManager())
    }
}
