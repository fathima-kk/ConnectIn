//
//  TagView.swift
//  ConnectIn
//

import SwiftUI

enum TagColor {
    case teal
    case gray
    case custom(foreground: Color, background: Color)
}

struct TagView: View {
    let text: String
    var color: TagColor = .teal

    private var colors: (foreground: Color, background: Color) {
        switch color {
        case .teal:
            return (AppTheme.Colors.cardBackground, AppTheme.Colors.secondary)
        case .gray:
            return (AppTheme.Colors.textPrimary, Color(hex: "#E5E7EB"))
        case let .custom(fg, bg):
            return (fg, bg)
        }
    }

    var body: some View {
        Text(text)
            .connectInCaption()
            .foregroundStyle(colors.foreground)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(colors.background, in: Capsule())
    }
}

// MARK: - Flow layout

struct TagFlowLayout: Layout {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let layout = computeFrames(subviews: subviews, maxWidth: maxWidth)
        return layout.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layout = computeFrames(subviews: subviews, maxWidth: bounds.width)
        for (index, frame) in layout.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func computeFrames(subviews: Subviews, maxWidth: CGFloat) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0

        let finiteWidth = maxWidth.isFinite && maxWidth > 0 ? maxWidth : .greatestFiniteMagnitude

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > finiteWidth, x > 0 {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            rowHeight = max(rowHeight, size.height)
            x += size.width + horizontalSpacing
            usedWidth = max(usedWidth, x - horizontalSpacing)
        }

        let totalHeight = y + rowHeight
        let widthOut = maxWidth.isFinite && maxWidth > 0 ? maxWidth : usedWidth
        return (CGSize(width: widthOut, height: totalHeight), frames)
    }
}

struct TagFlowView: View {
    let tags: [String]
    var color: TagColor = .teal
    var spacing: CGFloat = 8

    var body: some View {
        TagFlowLayout(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(tags, id: \.self) { tag in
                TagView(text: tag, color: color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            TagView(text: "Product Management", color: .teal)
            TagView(text: "Draft", color: .gray)
            TagFlowView(tags: ["Swift", "iOS", "Design", "Product", "Interviews"], color: .teal)
        }
        .padding()
    }
    .background(AppTheme.Colors.background)
}
