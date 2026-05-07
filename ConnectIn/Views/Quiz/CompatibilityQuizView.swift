//
//  CompatibilityQuizView.swift
//  ConnectIn
//

import SwiftUI

/// Five-question quiz that updates per-mentor match scores by industry, goals,
/// and personality. Lives in a sheet from `ProfileView`.
struct CompatibilityQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @State private var currentIndex: Int = 0
    @State private var answers: [QuizQuestion.Dimension: String] = [:]
    @State private var didFinish: Bool = false

    private var questions: [QuizQuestion] { QuizQuestion.library }
    private var question: QuizQuestion { questions[currentIndex] }

    private var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()

                if didFinish {
                    completionScreen
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    quizScreen
                        .transition(.opacity)
                }
            }
            .navigationTitle("Compatibility Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
    }

    // MARK: - Quiz screen

    private var quizScreen: some View {
        VStack(alignment: .leading, spacing: 20) {
            ProgressView(value: progress)
                .tint(AppTheme.Colors.secondary)

            Text("Question \(currentIndex + 1) of \(questions.count)")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Text(question.prompt)
                .connectInTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(question.options, id: \.self) { option in
                    optionButton(option)
                }
            }

            Spacer()

            HStack {
                if currentIndex > 0 {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) { currentIndex -= 1 }
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .connectInBody()
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .padding(20)
    }

    private func optionButton(_ option: String) -> some View {
        let selected = answers[question.dimension] == option
        return Button {
            withAnimation(.easeOut(duration: 0.18)) {
                answers[question.dimension] = option
            }
            // Auto-advance after a brief beat for momentum.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                advance()
            }
        } label: {
            HStack {
                Text(option)
                    .connectInBody()
                    .fontWeight(selected ? .semibold : .regular)
                    .foregroundStyle(selected ? AppTheme.Colors.primary : AppTheme.Colors.textPrimary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? AppTheme.Colors.accent.opacity(0.18) : AppTheme.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? AppTheme.Colors.secondary : AppTheme.Colors.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func advance() {
        if currentIndex < questions.count - 1 {
            withAnimation(.easeOut(duration: 0.22)) { currentIndex += 1 }
        } else {
            finish()
        }
    }

    private func finish() {
        let result = QuizResult(answers: answers, completedAt: Date())
        appState.quizResult = result
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            didFinish = true
        }
    }

    // MARK: - Completion screen

    private var completionScreen: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 40)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.Colors.accent.opacity(0.35), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 110
                        )
                    )
                    .frame(width: 220, height: 220)
                Image(systemName: "sparkles")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.secondary, AppTheme.Colors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("All set!")
                .connectInTitle()
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Your match scores now factor in your industry focus, goals, communication style, and personality.")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            PrimaryButton(title: "See My Matches", style: .primary) {
                appState.selectedTab = .browse
                dismiss()
            }
            .padding(.horizontal, 20)

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .padding(.top, 12)
        .sensoryFeedback(.success, trigger: didFinish)
    }
}

#Preview {
    CompatibilityQuizView()
        .environmentObject(AppState())
}
