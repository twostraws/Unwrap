//
//  QuickActionRouter.swift
//  Unwrap
//

import Foundation

@MainActor
final class QuickActionRouter {
    static let shared = QuickActionRouter()
    static let didReceiveAction = Notification.Name("UnwrapDidReceiveQuickAction")

    private var pendingType: String?

    private init() { }

    @discardableResult
    func enqueue(_ type: String) -> Bool {
        guard Self.tab(for: type) != nil else { return false }
        pendingType = type
        return true
    }

    @discardableResult
    func broadcast(_ type: String) -> Bool {
        guard Self.tab(for: type) != nil else { return false }
        NotificationCenter.default.post(name: Self.didReceiveAction, object: type)
        return true
    }

    func consumePendingType() -> String? {
        defer { pendingType = nil }
        return pendingType
    }

    static func tab(for type: String) -> AppTab? {
        switch type {
        case "com.hackingwithswift.unwrapswift.challenges":
            .challenges
        case "com.hackingwithswift.unwrapswift.news":
            .news
        default:
            nil
        }
    }
}
