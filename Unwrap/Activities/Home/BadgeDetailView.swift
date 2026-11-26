//
//  BadgeDetailView.swift
//  Unwrap
//

import SwiftUI

/// Describes one badge, shows progress toward it, and lets the user share it once it's earned.
struct BadgeDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let badge: Badge
    let user: User

    var body: some View {
        let isEarned = user.isBadgeEarned(badge)

        NavigationStack {
            VStack(spacing: 20) {
                BadgeIconView(badge: badge, isEarned: isEarned)
                    .frame(width: 96, height: 96)
                    .accessibilityHidden(true)

                Text(isEarned ? badge.description : badge.description + user.badgeProgress(badge))
                    .multilineTextAlignment(.center)

                if isEarned {
                    HomeShareLink(title: "Share", item: .badge(badge))
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(badge.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
