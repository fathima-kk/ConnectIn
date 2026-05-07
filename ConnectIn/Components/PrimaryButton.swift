//
//  PrimaryButton.swift
//  ConnectIn
//

import SwiftUI
import UIKit

struct PrimaryButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    var style: Style = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    /// When `true`, expands to max width (default). When `false`, sizes to content with horizontal padding.
    var fullWidth: Bool = true
    var action: () -> Void

    private var effectiveDisabled: Bool {
        isDisabled || isLoading
    }

    var body: some View {
        Button {
            guard !effectiveDisabled else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            ZStack {
                Text(title)
                    .connectInHeadline()
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(style == .primary ? AppTheme.Colors.cardBackground : AppTheme.Colors.secondary)
                }
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: 50)
            .padding(.horizontal, fullWidth ? 0 : 20)
            .foregroundStyle(foregroundColor)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppTheme.Colors.secondary, lineWidth: 1.5)
                }
            }
            .shadow(
                color: style == .primary ? AppTheme.Colors.secondary.opacity(0.35) : .clear,
                radius: 8,
                y: 4
            )
        }
        .buttonStyle(.plain)
        .opacity(effectiveDisabled ? 0.45 : 1)
        .disabled(effectiveDisabled)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return AppTheme.Colors.cardBackground
        case .secondary:
            return AppTheme.Colors.secondary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            AppTheme.Colors.secondary
        case .secondary:
            AppTheme.Colors.cardBackground
        }
    }
}

#Preview("Primary styles") {
    VStack(spacing: 16) {
        PrimaryButton(title: "Connect", style: .primary, isLoading: false) {}
        PrimaryButton(title: "Skip", style: .secondary) {}
        PrimaryButton(title: "Loading", style: .primary, isLoading: true) {}
        PrimaryButton(title: "Disabled", style: .primary, isDisabled: true) {}
        PrimaryButton(title: "Compact", style: .secondary, fullWidth: false) {}
    }
    .padding()
    .background(AppTheme.Colors.background)
}
