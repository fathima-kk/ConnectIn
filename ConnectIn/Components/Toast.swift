//
//  Toast.swift
//  ConnectIn
//

import SwiftUI

/// Lightweight toast banner that slides down from the top safe area.
struct Toast: Identifiable, Equatable {
    enum Style {
        case success
        case info
        case error

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .info: return "info.circle.fill"
            case .error: return "exclamationmark.triangle.fill"
            }
        }

        var tint: Color {
            switch self {
            case .success: return AppTheme.Colors.success
            case .info: return AppTheme.Colors.secondary
            case .error: return AppTheme.Colors.error
            }
        }
    }

    let id = UUID()
    var message: String
    var style: Style = .success
}

private struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    var duration: TimeInterval = 2.5

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast {
                    HStack(spacing: 10) {
                        Image(systemName: toast.style.icon)
                            .foregroundStyle(toast.style.tint)
                        Text(toast.message)
                            .connectInBody()
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(toast.style.tint.opacity(0.3), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: toast.id) {
                        try? await Task.sleep(for: .seconds(duration))
                        withAnimation(.easeInOut(duration: 0.25)) {
                            self.toast = nil
                        }
                    }
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: toast)
    }
}

extension View {
    func toast(_ toast: Binding<Toast?>, duration: TimeInterval = 2.5) -> some View {
        modifier(ToastModifier(toast: toast, duration: duration))
    }
}
