//
//  HomeView.swift
//  Unwrap
//

import StoreKit
import SwiftUI

struct HomeView: View {
    @Environment(User.self) private var user
    @Environment(\.requestReview) private var requestReview

    @State private var path = [HomeRoute]()
    @State private var selectedBadge: Badge?
    @State private var hasRequestedReviewThisSession = false

    let content: HomeContent
    let showTour: () -> Void

    var body: some View {
        NavigationStack(path: $path) {
            HomeDashboardView(
                user: user,
                badges: content.badges,
                selectBadge: { selectedBadge = $0 }
            )
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink("Help", value: HomeRoute.help)
                }
            }
            .navigationDestination(for: HomeRoute.self) { route in
                HomeDestinationView(
                    route: route,
                    content: content,
                    show: show,
                    showTour: showTour
                )
            }
        }
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailView(badge: badge, user: user)
        }
        .task(id: user.totalPoints) {
            requestReviewIfNeeded()
        }
    }

    private func show(_ route: HomeRoute) {
        path.append(route)
    }

    private func requestReviewIfNeeded() {
        guard user.totalPoints > 2_000 else { return }
        guard hasRequestedReviewThisSession == false else { return }
        guard Self.isDebugBuild == false else { return }

        hasRequestedReviewThisSession = true
        requestReview()
    }

    private static var isDebugBuild: Bool {
        #if DEBUG
            true
        #else
            false
        #endif
    }
}
