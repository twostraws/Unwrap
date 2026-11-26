//
//  QuickActionRouterTests.swift
//  UnwrapTests
//

import Foundation
import Synchronization
import Testing
@testable import Unwrap

@Suite("Home Screen quick actions", .serialized)
struct QuickActionRouterTests {
    private let challengesType = "com.hackingwithswift.unwrapswift.challenges"
    private let newsType = "com.hackingwithswift.unwrapswift.news"

    @Test("Every quick action declared in Info.plist opens a tab")
    func declaredActionsAreRoutable() throws {
        let items = try #require(
            Bundle.main.object(forInfoDictionaryKey: "UIApplicationShortcutItems") as? [[String: Any]]
        )
        let types = items.compactMap { $0["UIApplicationShortcutItemType"] as? String }

        #expect(types.isEmpty == false)
        #expect(types.count == items.count)

        for type in types {
            #expect(QuickActionRouter.tab(for: type) != nil, "No tab handles the quick action \(type).")
        }
    }

    @Test("Action types map to their own tabs and nothing else")
    func tabMapping() {
        #expect(QuickActionRouter.tab(for: challengesType) == .challenges)
        #expect(QuickActionRouter.tab(for: newsType) == .news)
        #expect(QuickActionRouter.tab(for: "com.hackingwithswift.unwrapswift.practice") == nil)
        #expect(QuickActionRouter.tab(for: "") == nil)
    }

    @Test("An action that launched the app is delivered exactly once")
    func pendingActionIsConsumedOnce() {
        let router = QuickActionRouter.shared
        _ = router.consumePendingType()

        #expect(router.enqueue(challengesType))
        #expect(router.consumePendingType() == challengesType)
        #expect(router.consumePendingType() == nil)
    }

    @Test("Only the most recent launch action is kept")
    func latestPendingActionWins() {
        let router = QuickActionRouter.shared
        _ = router.consumePendingType()

        #expect(router.enqueue(challengesType))
        #expect(router.enqueue(newsType))
        #expect(router.consumePendingType() == newsType)
    }

    @Test("Unknown actions are rejected without disturbing a pending one")
    func unknownActionsAreRejected() {
        let router = QuickActionRouter.shared
        _ = router.consumePendingType()

        #expect(router.enqueue("not-a-real-action") == false)
        #expect(router.consumePendingType() == nil)

        #expect(router.enqueue(newsType))
        #expect(router.enqueue("not-a-real-action") == false)
        #expect(router.consumePendingType() == newsType)
    }

    @Test("Actions received while running are broadcast only when a tab can handle them")
    func broadcast() {
        let log = NotificationLog()
        let observer = NotificationCenter.default.addObserver(
            forName: QuickActionRouter.didReceiveAction,
            object: nil,
            queue: nil
        ) { notification in
            log.record(notification.object as? String)
        }
        defer { NotificationCenter.default.removeObserver(observer) }

        #expect(QuickActionRouter.shared.broadcast(newsType))
        #expect(QuickActionRouter.shared.broadcast("not-a-real-action") == false)

        #expect(log.types == [newsType])
    }
}

/// Collects the action types posted to NotificationCenter, whichever thread they arrive on.
nonisolated private final class NotificationLog: Sendable {
    private let storage = Mutex<[String?]>([])

    var types: [String?] {
        storage.withLock { $0 }
    }

    func record(_ type: String?) {
        storage.withLock { $0.append(type) }
    }
}
