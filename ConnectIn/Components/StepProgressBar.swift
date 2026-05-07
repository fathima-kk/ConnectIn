//
//  StepProgressBar.swift
//  ConnectIn
//

import SwiftUI

/// Three-pill style progress indicator for the onboarding profile flow.
struct StepProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Capsule()
                        .fill(index < currentStep
                              ? AppTheme.Colors.accent
                              : AppTheme.Colors.accent.opacity(0.18))
                        .frame(height: 6)
                        .animation(.easeInOut(duration: 0.25), value: currentStep)
                }
            }
            Text("Step \(currentStep) of \(totalSteps)")
                .connectInCaption()
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        StepProgressBar(currentStep: 1, totalSteps: 3)
        StepProgressBar(currentStep: 2, totalSteps: 3)
        StepProgressBar(currentStep: 3, totalSteps: 3)
    }
    .padding()
    .background(AppTheme.Colors.background)
}
