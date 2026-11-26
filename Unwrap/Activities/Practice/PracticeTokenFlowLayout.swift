//
//  PracticeTokenFlowLayout.swift
//  Unwrap
//

import SwiftUI

struct PracticeTokenFlowLayout: Layout {
    struct Cache {
        var sizes = [CGSize]()
    }

    var spacing: CGFloat = 8

    func makeCache(subviews: Subviews) -> Cache {
        Cache(sizes: subviews.map { $0.sizeThatFits(.unspecified) })
    }

    func updateCache(_ cache: inout Cache, subviews: Subviews) {
        cache.sizes = subviews.map { $0.sizeThatFits(.unspecified) }
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let availableWidth = proposal.width ?? .infinity
        cache.sizes = measuredSizes(for: subviews, width: availableWidth)
        let frames = Self.frames(for: cache.sizes, width: availableWidth, spacing: spacing)
        let width = frames.map(\.maxX).max() ?? 0
        let height = frames.map(\.maxY).max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        cache.sizes = measuredSizes(for: subviews, width: bounds.width)
        let frames = Self.frames(for: cache.sizes, width: bounds.width, spacing: spacing)

        for (subview, frame) in zip(subviews, frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func measuredSizes(for subviews: Subviews, width: CGFloat) -> [CGSize] {
        subviews.map { subview in
            let intrinsicSize = subview.sizeThatFits(.unspecified)
            guard width.isFinite, intrinsicSize.width > width else {
                return intrinsicSize
            }

            let measuredSize = subview.sizeThatFits(ProposedViewSize(width: width, height: nil))
            return CGSize(width: min(measuredSize.width, width), height: measuredSize.height)
        }
    }

    static func frames(for sizes: [CGSize], width: CGFloat, spacing: CGFloat) -> [CGRect] {
        var result = [CGRect]()
        var position = CGPoint.zero
        var rowHeight = 0.0

        for proposedSize in sizes {
            let size = CGSize(
                width: width.isFinite ? min(proposedSize.width, max(width, 0)) : proposedSize.width,
                height: proposedSize.height
            )

            if position.x > 0, position.x + size.width > width {
                position.x = 0
                position.y += rowHeight + spacing
                rowHeight = 0
            }

            result.append(CGRect(origin: position, size: size))
            position.x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return result
    }
}
