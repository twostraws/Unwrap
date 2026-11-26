//
//  BadgeGridView.swift
//  Unwrap
//

import SwiftUI

struct BadgeGridView: View {
    let badges: [Badge]
    let user: User
    let select: (Badge) -> Void

    private let columns = [GridItem(.adaptive(minimum: 54), spacing: 6)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(badges) { badge in
                Button {
                    select(badge)
                } label: {
                    BadgeIconView(badge: badge, isEarned: user.isBadgeEarned(badge))
                        .frame(maxWidth: 60)
                        .frame(maxWidth: .infinity)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Badge \(badge.name)")
                .accessibilityValue(accessibilityValue(for: badge))
                .accessibilityHint("Shows badge details")
            }
        }
        .padding(.vertical, 8)
    }

    private func accessibilityValue(for badge: Badge) -> String {
        if user.isBadgeEarned(badge) {
            "Earned"
        } else {
            user.badgeProgress(badge).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
