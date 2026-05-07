//
//  PaywallView.swift
//  ConnectIn
//

import SwiftUI

/// ConnectIn Pro paywall — single tier, $4.99/mo, 7-day free trial.
///
/// Presented as a sheet from anywhere in the app that gates Pro features
/// (Sessions tab, mentor connection, compatibility quiz, etc).
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    /// Whether the user has already used their trial. When `true`, the CTA
    /// jumps straight to "Subscribe" instead of "Start free trial".
    private var trialUsed: Bool {
        appState.subscription.status == .expired || appState.subscription.startedAt != nil
    }

    private var primaryCtaLabel: String {
        switch appState.subscription.status {
        case .none: return "Start 7-day free trial"
        case .trialing, .active: return "You're in — close"
        case .expired: return "Renew for $4.99/mo"
        }
    }

    private let benefits: [(icon: String, title: String, detail: String)] = [
        ("checkmark.seal.fill",
         "Verified mentors only",
         "Every mentor's company + identity is hand-verified."),
        ("video.fill",
         "Unlimited sessions",
         "Templates, agendas, and shared goals — no per-session fees."),
        ("calendar",
         "Built-in scheduler",
         "Drop a template on the calendar in two taps."),
        ("flag.checkered",
         "Milestone tracking",
         "Both sides see growth over time on a shared dashboard."),
        ("sparkles",
         "Compatibility matching",
         "Quiz-driven match scores by industry, goals, and personality."),
        ("text.bubble.fill",
         "Message templates",
         "Pre-written intros so you never face a blank page.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    heroBanner
                    priceCard
                    benefitsList
                    valuePropFooter
                }
                .padding(20)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomCta
            }
        }
    }

    // MARK: - Hero

    private var heroBanner: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.Colors.accent.opacity(0.5), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.secondary, AppTheme.Colors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(height: 180)

            VStack(spacing: 6) {
                Text(Subscription.planName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Mentorship that actually moves you forward.")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Price card

    private var priceCard: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$\(String(format: "%.2f", Subscription.monthlyPrice))")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                Text("/ month")
                    .connectInBody()
                    .foregroundStyle(.white.opacity(0.85))
            }
            Text("Start with a \(Subscription.trialDays)-day free trial. Cancel anytime.")
                .connectInCaption()
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.Colors.accent.opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Benefits

    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Everything in Pro")
                .connectInHeadline()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            VStack(spacing: 0) {
                ForEach(Array(benefits.enumerated()), id: \.offset) { idx, item in
                    if idx > 0 {
                        Divider().background(AppTheme.Colors.divider)
                    }
                    benefitRow(icon: item.icon, title: item.title, detail: item.detail)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
            )
        }
    }

    private func benefitRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .connectInBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(detail)
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.vertical, 12)
    }

    // MARK: - Value prop footer

    private var valuePropFooter: some View {
        VStack(spacing: 8) {
            Text("Why a subscription?")
                .connectInBody()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Subscriptions let us pay verification staff, run trust + safety, and keep ConnectIn ad-free. No data sales, no upsells inside the app.")
                .connectInCaption()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }

    // MARK: - Bottom CTA

    private var bottomCta: some View {
        VStack(spacing: 8) {
            PrimaryButton(title: primaryCtaLabel, style: .primary) {
                handlePrimaryTap()
            }
            HStack(spacing: 14) {
                Button("Restore purchase") {}
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("·")
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Button("Terms") {}
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("·")
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Button("Privacy") {}
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .background(AppTheme.Colors.background.opacity(0.96))
    }

    private func handlePrimaryTap() {
        switch appState.subscription.status {
        case .none:
            appState.startFreeTrial()
        case .expired:
            appState.subscribeNow()
        case .trialing, .active:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { dismiss() }
    }
}

#Preview {
    PaywallView()
        .environmentObject(AppState())
}
