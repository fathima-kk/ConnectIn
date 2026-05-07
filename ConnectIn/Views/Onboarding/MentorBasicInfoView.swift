//
//  MentorBasicInfoView.swift
//  ConnectIn
//
//  Mentor onboarding — Step 1 of 3.
//  Collects the mentor's professional background so students see who they're
//  about to learn from at a glance.
//

import SwiftUI

struct MentorBasicInfoView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var profileVM: ProfileViewModel

    @State private var showingPhotoOptions: Bool = false
    @State private var hasSeeded: Bool = false

    /// Step is valid once we have a name, job title, and company. Years of
    /// experience always has a default.
    private var isStepValid: Bool {
        !profileVM.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !profileVM.jobTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !profileVM.company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                StepProgressBar(currentStep: 1, totalSteps: 3)

                header

                photoPicker

                VStack(spacing: 16) {
                    fullNameField
                    jobTitleField
                    companyField
                    yearsExperiencePicker
                }

                verificationNote

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
            // Run once: mark this user as a mentor and seed any data we
            // already have from sign-up (name, email).
            guard !hasSeeded else { return }
            hasSeeded = true
            profileVM.role = .mentor
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
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your professional story")
                .connectInLargeTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Mentees will see this on your card before they reach out.")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    /// Same look as the student photo picker so the two flows feel like one
    /// product, just with mentor-appropriate copy.
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

                    Image(systemName: "person.badge.shield.checkmark.fill")
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

                Text("Add a professional photo")
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var fullNameField: some View {
        CustomTextField(
            label: "Full Name",
            placeholder: "Jane Doe",
            text: $profileVM.fullName,
            icon: "person.fill"
        )
        .textContentType(.name)
        .textInputAutocapitalization(.words)
    }

    private var jobTitleField: some View {
        CustomTextField(
            label: "Current Role",
            placeholder: "e.g. Senior Product Manager",
            text: $profileVM.jobTitle,
            icon: "briefcase.fill"
        )
        .textInputAutocapitalization(.words)
    }

    private var companyField: some View {
        CustomTextField(
            label: "Company",
            placeholder: "e.g. Figma",
            text: $profileVM.company,
            icon: "building.2.fill"
        )
        .textInputAutocapitalization(.words)
    }

    private var yearsExperiencePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Years of Experience")
                .connectInCaption()
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Menu {
                Picker("Years of Experience", selection: $profileVM.yearsExperience) {
                    ForEach(Array(ProfileViewModel.yearsExperienceRange), id: \.self) { years in
                        Text("\(years) year\(years == 1 ? "" : "s")").tag(years)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(width: 20)
                    Text("\(profileVM.yearsExperience) year\(profileVM.yearsExperience == 1 ? "" : "s")")
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

    /// We don't run real verification yet, but signaling the intent here is
    /// important — it sets expectations for the badge mentors will see on
    /// their card later.
    private var verificationNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(AppTheme.Colors.accent)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 2) {
                Text("Verified mentor badge")
                    .connectInCaption()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("We'll confirm your role and company over email before mentees see a verified badge on your profile.")
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(AppTheme.Colors.accent.opacity(0.35), lineWidth: 1)
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            NavigationLink(value: OnboardingRoute.mentorExpertise) {
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
        MentorBasicInfoView()
            .environmentObject(AppState())
            .environmentObject({
                let vm = ProfileViewModel()
                vm.role = .mentor
                return vm
            }())
    }
}
