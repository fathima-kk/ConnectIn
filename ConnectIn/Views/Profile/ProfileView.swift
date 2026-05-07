//
//  ProfileView.swift
//  ConnectIn
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var connectionsManager: ConnectionsManager

    @EnvironmentObject private var sessionsManager: SessionsManager

    @State private var showingEditSheet: Bool = false
    @State private var showingSignOutConfirm: Bool = false
    @State private var showingResetDemoConfirm: Bool = false
    @State private var showingQuiz: Bool = false
    @State private var showingPaywall: Bool = false
    @State private var showingCancelConfirm: Bool = false

    private var user: User {
        appState.currentUser ?? SampleData.currentUser
    }

    private var isMentor: Bool {
        user.role == .mentor
    }

    /// Profile completion is the share of role-appropriate components filled.
    /// Each side has 5 weighted components. Affiliation is optional for
    /// mentees so we don't count it.
    private var completionPercentage: Int {
        var score = 0
        if !user.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { score += 1 }
        if !user.bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { score += 1 }
        if !user.interests.isEmpty { score += 1 }
        if !user.goals.isEmpty { score += 1 }

        if isMentor {
            if !(user.jobTitle ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { score += 1 }
        } else {
            if !user.major.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { score += 1 }
        }

        return Int((Double(score) / 5.0) * 100)
    }

    /// Items the user could still fill in. Different list per role so we
    /// don't tell a mentor to "Add: University".
    private var missingSections: [String] {
        var missing: [String] = []
        if user.bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            missing.append(isMentor ? "Why I mentor" : "Bio")
        }
        if user.interests.isEmpty {
            missing.append(isMentor ? "Expertise" : "Interests")
        }
        if user.goals.isEmpty {
            missing.append(isMentor ? "Ways I help" : "Goals")
        }
        if isMentor {
            if (user.jobTitle ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { missing.append("Role") }
            if (user.company ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { missing.append("Company") }
        } else {
            if user.major.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { missing.append("Field of focus") }
        }
        return missing
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ProfileHeader(
                    imageURL: user.profileImageURL,
                    name: user.fullName,
                    role: user.role,
                    subtitle: subtitle,
                    isEditable: true,
                    onEditTap: { showingEditSheet = true }
                )

                if completionPercentage < 100 {
                    completionBanner
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Mentees see the subscription/quiz cards. Mentors see a
                // "free forever" card and skip the matching quiz — mentees
                // are the ones being matched, not mentors.
                if isMentor {
                    mentorFreePlanCard
                } else {
                    membershipCard
                    compatibilityQuizCard
                }

                aboutSection
                detailsSection
                interestsSection
                goalsSection
                settingsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .animation(.easeInOut(duration: 0.3), value: completionPercentage)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ProfileEditSheet(user: user) { updated in
                appState.updateUser(updated)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingQuiz) {
            CompatibilityQuizView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .confirmationDialog(
            "Cancel ConnectIn Pro?",
            isPresented: $showingCancelConfirm,
            titleVisibility: .visible
        ) {
            Button("Cancel membership", role: .destructive) {
                appState.cancelSubscription()
            }
            Button("Keep Pro", role: .cancel) {}
        } message: {
            Text("You'll lose access to verified mentors, structured sessions, and milestone tracking.")
        }
        .confirmationDialog(
            "Sign out of ConnectIn?",
            isPresented: $showingSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                appState.logout()
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Reset demo data?",
            isPresented: $showingResetDemoConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                connectionsManager.reset()
                sessionsManager.reset()
                appState.enterDemoMode()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This restores Sofia's profile and the seeded mentor connections.")
        }
    }

    // MARK: - Completion banner

    private var completionBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Profile \(completionPercentage)% complete", systemImage: "chart.bar.fill")
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.primary)
                Spacer()
                Text("\(completionPercentage)%")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.accent)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.Colors.accent.opacity(0.15))
                    Capsule()
                        .fill(AppTheme.Colors.accent)
                        .frame(width: geo.size.width * CGFloat(completionPercentage) / 100)
                        .animation(.easeOut(duration: 0.4), value: completionPercentage)
                }
            }
            .frame(height: 8)

            Text(isMentor
                 ? "Complete your profile so students know what you can help with."
                 : "Complete your profile to get better matches.")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)

            if !missingSections.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Add: \(missingSections.joined(separator: ", "))")
                        .connectInCaption()
                        .lineLimit(2)
                }
                .foregroundStyle(AppTheme.Colors.accent)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .strokeBorder(AppTheme.Colors.accent.opacity(0.3), lineWidth: 1)
        }
    }

    /// One-line subtitle under the user's name on the profile header. Mentors
    /// show "Job Title · Company"; mentees show "School/Company · Field".
    private var subtitle: String? {
        let parts: [String]
        if isMentor {
            parts = [user.jobTitle ?? "", user.company ?? ""]
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        } else {
            parts = [user.university, user.major]
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    // MARK: - Membership

    /// Mentor-side replacement for the membership card. Mentors don't pay
    /// — this card celebrates that and reinforces the value they're
    /// providing to the platform.
    private var mentorFreePlanCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Mentor account")
                        .connectInHeadline()
                        .foregroundStyle(.white)
                    Text("Free")
                        .connectInCaption()
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.white.opacity(0.95)))
                }
                Text("Thanks for showing up for the next generation. Mentors get every feature, no fees.")
                    .connectInCaption()
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
        )
    }

    private var membershipCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 44, height: 44)
                    Image(systemName: appState.subscription.hasAccess ? "checkmark.seal.fill" : "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(Subscription.planName)
                            .connectInHeadline()
                            .foregroundStyle(.white)
                        membershipStatusPill
                    }
                    Text(membershipDetail)
                        .connectInCaption()
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            HStack(spacing: 10) {
                Button {
                    showingPaywall = true
                } label: {
                    Text(membershipPrimaryLabel)
                        .connectInBody()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(.white, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                if appState.subscription.hasAccess {
                    Button {
                        showingCancelConfirm = true
                    } label: {
                        Text("Cancel")
                            .connectInBody()
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
        )
    }

    private var membershipStatusPill: some View {
        Text(appState.subscription.displayLabel)
            .connectInCaption()
            .fontWeight(.bold)
            .foregroundStyle(AppTheme.Colors.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Capsule().fill(.white.opacity(0.95)))
    }

    private var membershipDetail: String {
        switch appState.subscription.status {
        case .none:
            return "Start a \(Subscription.trialDays)-day free trial. Then $\(String(format: "%.2f", Subscription.monthlyPrice))/mo."
        case .trialing:
            let days = appState.subscription.daysUntilRenewal ?? 0
            return "Free trial ends in \(days) day\(days == 1 ? "" : "s"). Billing $\(String(format: "%.2f", Subscription.monthlyPrice))/mo after."
        case .active:
            if let renews = appState.subscription.renewsAt {
                let f = DateFormatter()
                f.dateStyle = .medium
                return "Renews \(f.string(from: renews)) for $\(String(format: "%.2f", Subscription.monthlyPrice))."
            }
            return "Renews monthly at $\(String(format: "%.2f", Subscription.monthlyPrice))."
        case .expired:
            return "Membership ended. Renew to unlock Pro again."
        }
    }

    private var membershipPrimaryLabel: String {
        switch appState.subscription.status {
        case .none: return "Start free trial"
        case .trialing, .active: return "Manage plan"
        case .expired: return "Renew membership"
        }
    }

    // MARK: - Compatibility quiz

    private var compatibilityQuizCard: some View {
        Button {
            showingQuiz = true
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.accent.opacity(0.20))
                        .frame(width: 44, height: 44)
                    Image(systemName: appState.quizResult?.isComplete == true
                          ? "checkmark.seal.fill"
                          : "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Compatibility quiz")
                            .connectInHeadline()
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        if appState.quizResult?.isComplete == true {
                            Text("Done")
                                .connectInCaption()
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(AppTheme.Colors.success))
                        }
                    }
                    Text(appState.quizResult?.isComplete == true
                         ? "Retake the quiz any time to update your match scores."
                         : "5 questions to improve your match scores by industry, goals, and personality.")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .strokeBorder(AppTheme.Colors.cardBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sections (role-aware)
    //
    // Each section header re-labels based on `isMentor` so the same view
    // renders both onboarding flows' data. We don't fork into two giant
    // ProfileView types — the data shape is the same; only labels differ.

    private var aboutSection: some View {
        ProfileSection(title: isMentor ? "Why I mentor" : "About") {
            if user.bio.isEmpty {
                Text(isMentor ? "Add why you mentor" : "Add a bio")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.8))
                    .italic()
            } else {
                Text(user.bio)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private var detailsSection: some View {
        if isMentor {
            mentorDetailsSection
        } else {
            studentDetailsSection
        }
    }

    /// "Details" section for mentees. The school + field rows always show;
    /// "Class of" + first-gen only show for users who marked themselves as
    /// currently a student (sentinel: `graduationYear > 0`).
    private var studentDetailsSection: some View {
        let isCurrentStudent = user.graduationYear > 0
        return ProfileSection(title: "Details") {
            VStack(spacing: 0) {
                detailRow(icon: "building.2.fill",
                          label: "School / Company",
                          value: user.university.isEmpty ? "Not set" : user.university)
                Divider().padding(.leading, 48)
                detailRow(icon: "sparkles",
                          label: "Field of focus",
                          value: user.major.isEmpty ? "Not set" : user.major)
                if isCurrentStudent {
                    Divider().padding(.leading, 48)
                    detailRow(icon: "calendar",
                              label: "Class of",
                              value: String(user.graduationYear))
                }
                if user.isFirstGen {
                    Divider().padding(.leading, 48)
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.accent)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.Colors.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                        Text("First-generation student")
                            .connectInBody()
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
            }
        }
    }

    private var mentorDetailsSection: some View {
        ProfileSection(title: "Professional") {
            VStack(spacing: 0) {
                detailRow(icon: "briefcase.fill",
                          label: "Role",
                          value: (user.jobTitle ?? "").isEmpty ? "Not set" : user.jobTitle!)
                Divider().padding(.leading, 48)
                detailRow(icon: "building.2.fill",
                          label: "Company",
                          value: (user.company ?? "").isEmpty ? "Not set" : user.company!)
                Divider().padding(.leading, 48)
                detailRow(icon: "clock.fill",
                          label: "Experience",
                          value: user.yearsExperience.map { "\($0) year\($0 == 1 ? "" : "s")" } ?? "Not set")
                Divider().padding(.leading, 48)
                detailRow(icon: "calendar",
                          label: "Availability",
                          value: (user.availability ?? "").isEmpty ? "Not set" : user.availability!)
                Divider().padding(.leading, 48)
                detailRow(icon: "person.3.fill",
                          label: "Mentee capacity",
                          value: user.maxMentees.map { "Up to \($0)" } ?? "Not set")
            }
        }
    }

    /// Tags. Same data field on either side, only the heading changes.
    private var interestsSection: some View {
        ProfileSection(title: isMentor ? "Expertise" : "Interests") {
            if user.interests.isEmpty {
                Text(isMentor ? "No expertise added yet" : "No interests added yet")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            } else {
                TagFlowView(tags: user.interests, color: .teal)
            }
        }
    }

    /// Tags. For students these are career goals; for mentors these are the
    /// concrete ways they help (e.g. "Resume reviews").
    private var goalsSection: some View {
        ProfileSection(title: isMentor ? "Ways I help" : "Goals") {
            if user.goals.isEmpty {
                Text(isMentor ? "No areas added yet" : "No goals set yet")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(user.goals, id: \.self) { item in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: isMentor ? "hands.sparkles.fill" : "checkmark.circle.fill")
                                .foregroundStyle(isMentor ? AppTheme.Colors.accent : AppTheme.Colors.success)
                            Text(item)
                                .connectInBody()
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                        }
                    }
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 12) {
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit Profile", systemImage: "square.and.pencil")
                    .connectInHeadline()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppTheme.Colors.secondary, in: RoundedRectangle(cornerRadius: 12))
                    .shadow(color: AppTheme.Colors.secondary.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)

            if appState.isDemoMode {
                Button {
                    showingResetDemoConfirm = true
                } label: {
                    Label("Reset Demo", systemImage: "arrow.counterclockwise")
                        .connectInHeadline()
                        .foregroundStyle(AppTheme.Colors.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.Colors.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            Button {
                showingSignOutConfirm = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .connectInHeadline()
                    .foregroundStyle(AppTheme.Colors.error)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(AppTheme.Colors.error.opacity(0.3), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
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
}

// MARK: - ProfileSection

private struct ProfileSection<Content: View>: View {
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
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }
}

// MARK: - ProfileEditSheet

/// Single edit sheet that handles both roles. Student-only and mentor-only
/// fields are wrapped in `if isMentor / else` so a mentor never sees a
/// "First-generation student" toggle (and vice-versa).
struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss

    let user: User
    let onSave: (User) -> Void

    private var isMentor: Bool {
        user.role == .mentor
    }

    // Shared fields (both roles)
    @State private var fullName: String = ""
    @State private var bio: String = ""
    @State private var interests: [String] = []
    @State private var goals: [String] = []

    // Student-only
    @State private var university: String = ""
    @State private var major: String = ""
    @State private var graduationYear: Int = Calendar.current.component(.year, from: Date()) + 1
    @State private var isFirstGen: Bool = false

    // Mentor-only
    @State private var jobTitle: String = ""
    @State private var company: String = ""
    @State private var yearsExperience: Int = 3
    @State private var availability: String = ""
    @State private var maxMentees: Int = 3

    @State private var newInterest: String = ""
    @State private var newGoal: String = ""

    private var canSave: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CustomTextField(
                        label: "Full Name",
                        placeholder: "Jane Doe",
                        text: $fullName,
                        icon: "person.fill"
                    )

                    if isMentor {
                        mentorFields
                    } else {
                        studentFields
                    }

                    CustomTextEditor(
                        label: isMentor ? "Why I mentor" : "Bio",
                        text: $bio,
                        placeholder: isMentor
                            ? "Share what kind of mentor you are…"
                            : "Tell mentors about yourself…",
                        showsCharacterCount: true
                    )

                    listEditor(
                        title: isMentor ? "Expertise" : "Interests",
                        items: $interests,
                        newItem: $newInterest,
                        placeholder: isMentor ? "Add an expertise area" : "Add an interest"
                    )

                    listEditor(
                        title: isMentor ? "Ways I help" : "Goals",
                        items: $goals,
                        newItem: $newGoal,
                        placeholder: isMentor ? "Add a way you help" : "Add a goal"
                    )
                }
                .padding(20)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            .onAppear { seed() }
        }
    }

    // MARK: - Student fields

    private var studentFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            CustomTextField(
                label: "University",
                placeholder: "Your school",
                text: $university,
                icon: "building.columns.fill"
            )

            CustomTextField(
                label: "Major",
                placeholder: "Field of study",
                text: $major,
                icon: "book.fill"
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Graduation Year")
                    .connectInCaption()
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Picker("Graduation Year", selection: $graduationYear) {
                    ForEach(Array(ProfileViewModel.graduationYearRange), id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.segmented)
            }

            Toggle(isOn: $isFirstGen) {
                Text("First-generation student")
                    .connectInBody()
            }
            .tint(AppTheme.Colors.accent)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12).strokeBorder(AppTheme.Colors.inputBorder, lineWidth: 1)
            }
        }
    }

    // MARK: - Mentor fields

    private var mentorFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            CustomTextField(
                label: "Current Role",
                placeholder: "e.g. Senior Product Manager",
                text: $jobTitle,
                icon: "briefcase.fill"
            )

            CustomTextField(
                label: "Company",
                placeholder: "e.g. Figma",
                text: $company,
                icon: "building.2.fill"
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Years of Experience")
                    .connectInCaption()
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Stepper(value: $yearsExperience, in: ProfileViewModel.yearsExperienceRange, step: 1) {
                    Text("\(yearsExperience) year\(yearsExperience == 1 ? "" : "s")")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
                .tint(AppTheme.Colors.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12).strokeBorder(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
            }

            CustomTextField(
                label: "Availability",
                placeholder: "e.g. Tue/Thu evenings (PT)",
                text: $availability,
                icon: "calendar"
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Mentee capacity")
                    .connectInCaption()
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Stepper(value: $maxMentees, in: ProfileViewModel.maxMenteesRange, step: 1) {
                    Text("Up to \(maxMentees) at a time")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
                .tint(AppTheme.Colors.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12).strokeBorder(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
            }
        }
    }

    private func seed() {
        fullName = user.fullName
        bio = user.bio
        interests = user.interests
        goals = user.goals

        university = user.university
        major = user.major
        graduationYear = max(user.graduationYear, ProfileViewModel.graduationYearRange.lowerBound)
        isFirstGen = user.isFirstGen

        jobTitle = user.jobTitle ?? ""
        company = user.company ?? ""
        yearsExperience = user.yearsExperience ?? 3
        availability = user.availability ?? ""
        maxMentees = user.maxMentees ?? 3
    }

    @ViewBuilder
    private func listEditor(
        title: String,
        items: Binding<[String]>,
        newItem: Binding<String>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .connectInCaption()
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            if !items.wrappedValue.isEmpty {
                TagFlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                    ForEach(items.wrappedValue, id: \.self) { item in
                        Button {
                            withAnimation {
                                items.wrappedValue.removeAll { $0 == item }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(item)
                                    .connectInCaption()
                                    .fontWeight(.semibold)
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.Colors.accent, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack(spacing: 8) {
                TextField(placeholder, text: newItem)
                    .connectInBody()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).strokeBorder(AppTheme.Colors.inputBorder, lineWidth: 1)
                    }
                    .onSubmit { addItem(items: items, newItem: newItem) }

                Button {
                    addItem(items: items, newItem: newItem)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(AppTheme.Colors.accent, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(newItem.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func addItem(items: Binding<[String]>, newItem: Binding<String>) {
        let trimmed = newItem.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !items.wrappedValue.contains(trimmed) {
            withAnimation { items.wrappedValue.append(trimmed) }
        }
        newItem.wrappedValue = ""
    }

    private func save() {
        var updated = user
        updated.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.interests = interests
        updated.goals = goals

        if isMentor {
            updated.jobTitle = jobTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.company = company.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.yearsExperience = yearsExperience
            updated.availability = availability.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.maxMentees = maxMentees
        } else {
            updated.university = university.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.major = major.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.graduationYear = graduationYear
            updated.isFirstGen = isFirstGen
        }

        onSave(updated)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject({
                let s = AppState()
                s.currentUser = SampleData.currentUser
                return s
            }())
            .environmentObject(ConnectionsManager())
            .environmentObject(SessionsManager())
    }
}
