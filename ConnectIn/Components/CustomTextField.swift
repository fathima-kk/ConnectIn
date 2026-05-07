//
//  CustomTextField.swift
//  ConnectIn
//

import SwiftUI

struct CustomTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    private var borderColor: Color {
        if errorMessage != nil { return AppTheme.Colors.error }
        return isFocused ? AppTheme.Colors.secondary : AppTheme.Colors.inputBorder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .connectInCaption()
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(width: 20)
                }

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .focused($isFocused)
            }
            .padding(14)
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: isFocused || errorMessage != nil ? 2 : 1)
            }

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.error)
            }
        }
    }
}

struct CustomTextEditor: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var errorMessage: String? = nil
    var showsCharacterCount: Bool = false

    @FocusState private var isFocused: Bool

    private var borderColor: Color {
        if errorMessage != nil { return AppTheme.Colors.error }
        return isFocused ? AppTheme.Colors.secondary : AppTheme.Colors.inputBorder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .connectInCaption()
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                if showsCharacterCount {
                    Text("\(text.count)")
                        .connectInCaption()
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .connectInBody()
                        .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.7))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .focused($isFocused)
            }
            .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: isFocused || errorMessage != nil ? 2 : 1)
            }

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .connectInCaption()
                    .foregroundStyle(AppTheme.Colors.error)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            CustomTextField(
                label: "Email",
                placeholder: "you@example.com",
                text: .constant(""),
                icon: "envelope.fill",
                errorMessage: nil
            )
            CustomTextField(
                label: "Password",
                placeholder: "••••••••",
                text: .constant(""),
                icon: "lock.fill",
                isSecure: true,
                errorMessage: "Too short"
            )
            CustomTextEditor(
                label: "Bio",
                text: .constant("Hello"),
                placeholder: "Tell us about yourself…",
                showsCharacterCount: true
            )
        }
        .padding()
    }
    .background(AppTheme.Colors.background)
}
