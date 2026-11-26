//
//  UnwrapRootView.swift
//  Unwrap
//

import SwiftUI

struct UnwrapRootView: View {
    @Environment(\.displayScale) private var displayScale
    @Environment(\.scenePhase) private var scenePhase
    @Environment(User.self) private var user
    @Environment(NewsStore.self) private var newsStore
    @Environment(ChallengesModel.self) private var challengesModel

    @State private var selectedTab = AppTab.home
    @State private var isTourPresented = false

    let homeContent: HomeContent

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                HomeView(
                    content: homeContent,
                    showTour: { isTourPresented = true }
                )
            }

            Tab("Learn", systemImage: "graduationcap.fill", value: .learn) {
                LearnView()
            }

            Tab("Practice", systemImage: "chart.line.uptrend.xyaxis", value: .practice) {
                PracticeView()
            }

            Tab("Challenges", systemImage: "trophy.fill", value: .challenges) {
                ChallengesView(model: challengesModel)
            }

            Tab("News", systemImage: "newspaper.fill", value: .news) {
                NewsView(store: newsStore)
            }
            .badge(newsStore.hasNewArticles && selectedTab != .news ? Text("★") : nil)
        }
        .tourPresentation(isPresented: $isTourPresented) {
            WelcomeTourView(
                items: homeContent.tourItems,
                closeAction: { isTourPresented = false }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            user.reconcileStreak(at: .now)
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: NSUbiquitousKeyValueStore.didChangeExternallyNotification
            )
        ) { notification in
            synchronizeUserAfterCloudChange(notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: QuickActionRouter.didReceiveAction)) { notification in
            guard let type = notification.object as? String else { return }
            handleShortcut(type)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                User.requestCloudSynchronization()
            }
        }
        .onChange(of: user.latestNewsArticle) {
            newsStore.synchronizeSeenState()
        }
        .task {
            if let type = QuickActionRouter.shared.consumePendingType() {
                handleShortcut(type)
            }

            await presentFirstRunTourIfNeeded()
        }
        .task {
            guard newsStore.state == .idle, newsStore.isVisible == false else { return }
            await newsStore.load(imageScale: Double(displayScale))
        }
    }

    private func synchronizeUserAfterCloudChange(_ notification: Notification) {
        // Running out of iCloud space isn't new data from another device, so there is nothing to adopt.
        let reason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
        guard reason != NSUbiquitousKeyValueStoreQuotaViolationChange else { return }

        let changedKeys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String]
        guard changedKeys?.contains(User.liveUserKey) == true else { return }
        guard let cloudUser = User.synchronizeAfterCloudChange() else { return }

        user.replaceProgress(with: cloudUser)
        user.reconcileStreak(at: .now)
    }

    private func handleShortcut(_ type: String) {
        guard let tab = QuickActionRouter.tab(for: type) else { return }
        selectedTab = tab
    }

    private func presentFirstRunTourIfNeeded() async {
        let key = "ShownFirstRun"
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: key) == false else { return }

        try? await Task.sleep(for: .seconds(1))
        guard Task.isCancelled == false, defaults.bool(forKey: key) == false else { return }

        defaults.set(true, forKey: key)
        isTourPresented = true
    }
}
