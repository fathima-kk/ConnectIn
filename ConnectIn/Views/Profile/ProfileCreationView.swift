//
//  ProfileCreationView.swift
//  ConnectIn
//
//  Step 1 of 3 — basic info collected from new users.
//

import SwiftUI

struct ProfileCreationView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var profileVM: ProfileViewModel

    let role: UserRole

    @State private var showingFirstGenInfo: Bool = false
    @State private var showingPhotoOptions: Bool = false
    @State private var hasSeeded: Bool = false

    init(role: UserRole = .mentee) {
        self.role = role
    }

    /// Mentees come from many places — current students, recent grads,
    /// career-switchers — so we only require name + a focus area. Affiliation
    /// (school or company) is encouraged but optional.
    private var isStepValid: Bool {
        !profileVM.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !profileVM.major.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                StepProgressBar(currentStep: 1, totalSteps: 3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tell us about yourself")
                        .connectInLargeTitle()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text("This helps mentors get to know you at a glance — whether you're a student, recent grad, or career-changer.")
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                photoPicker

                VStack(spacing: 16) {
                    CustomTextField(
                        label: "Full Name",
                        placeholder: "Jane Doe",
                        text: $profileVM.fullName,
                        icon: "person.fill"
                    )
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)

                    affiliationField
                    focusField
                    currentStudentToggle
                    if profileVM.isCurrentStudent {
                        graduationYearPicker
                        firstGenToggle
                    }
                }

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
        .onAppear {
            guard !hasSeeded else { return }
            hasSeeded = true
            profileVM.role = role
            profileVM.seed(from: appState.currentUser)
        }
        .confirmationDialog("Profile photo", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
            Button("Take Photo") {}
            Button("Choose from Library") {}
            Button("Remove Photo", role: .destructive) {
                profileVM.profileImageURL = nil
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Photo upload coming soon.")
        }
        .alert("First-generation student", isPresented: $showingFirstGenInfo) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text("First-gen means you're the first in your immediate family to attend college. We use this to help match you with mentors who've shared similar journeys.")
        }
    }

    // MARK: - Sections

    private var photoPicker: some View {
        Button {
            showingPhotoOptions = true
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.Colors.secondary, AppTheme.Colors.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)

                    Circle()
                        .fill(AppTheme.Colors.accent)
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .overlay {
                            Circle().strokeBorder(AppTheme.Colors.background, lineWidth: 3)
                        }
                        .offset(x: 38, y: 38)
                }

                Text("Add profile photo")
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    /// "Where you study or work" — works for current students, recent grads,
    /// and people who already have a job but are exploring something new.
    private var affiliationField: some View {
        VStack(alignment: .leading, spacing: 6) {
            CustomTextField(
                label: "School or Company (optional)",
                placeholder: "e.g. SF State, or Stripe",
                text: $profileVM.university,
                icon: "building.2.fill"
            )
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)

            Text("Optional. Helps mentors find common ground.")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    /// Field/focus area — major for students, role for working folks.
    private var focusField: some View {
        CustomTextField(
            label: "Field or Focus",
            placeholder: "e.g. Product Management, Computer Science",
            text: $profileVM.major,
            icon: "sparkles"
        )
        .textInputAutocapitalization(.words)
    }

    /// Hides graduation year + first-gen until the user explicitly says
    /// they're a current student — keeps the form short for everyone else.
    private var currentStudentToggle: some View {
        Toggle(isOn: $profileVM.isCurrentStudent) {
            Text("I'm currently a student")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
        .tint(AppTheme.Colors.accent)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(AppTheme.Colors.inputBorder, lineWidth: 1)
        }
    }

    private var graduationYearPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Graduation Year")
                .connectInCaption()
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Menu {
                Picker("Graduation Year", selection: $profileVM.graduationYear) {
                    ForEach(Array(ProfileViewModel.graduationYearRange), id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(width: 20)
                    Text(String(profileVM.graduationYear))
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding(14)
                .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppTheme.Colors.inputBorder, lineWidth: 1)
                }
            }
        }
    }

    private var firstGenToggle: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Toggle(isOn: $profileVM.isFirstGen) {
                    HStack(spacing: 6) {
                        Text("First-generation student?")
                            .connectInBody()
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Button {
                            showingFirstGenInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("More info about first-generation student")
                        .accessibilityHint("Shows a description of what first-generation means")
                    }
                }
                .tint(AppTheme.Colors.accent)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(AppTheme.Colors.inputBorder, lineWidth: 1)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            NavigationLink(value: OnboardingRoute.interests) {
                Text("Continue")
                    .connectInHeadline()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(AppTheme.Colors.cardBackground)
                    .background(AppTheme.Colors.secondary, in: RoundedRectangle(cornerRadius: 12))
                    .shadow(color: AppTheme.Colors.secondary.opacity(0.35), radius: 8, y: 4)
                    .opacity(isStepValid ? 1 : 0.45)
            }
            .buttonStyle(.plain)
            .disabled(!isStepValid)

            Button {
                skip()
            } label: {
                Text("Skip for now")
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
    }

    private func skip() {
        let user = profileVM.makeUser(id: appState.currentUser?.id ?? UUID())
        appState.completeOnboarding(user: user)
    }
}

#Preview {
    NavigationStack {
        ProfileCreationView(role: .mentee)
            .environmentObject(AppState())
            .environmentObject(ProfileViewModel())
    }
}
