//
//  UnwrapWindowSceneDelegate.swift
//  Unwrap
//

import UIKit

final class UnwrapWindowSceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let shortcutItem = connectionOptions.shortcutItem else { return }
        QuickActionRouter.shared.enqueue(shortcutItem.type)
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem
    ) async -> Bool {
        QuickActionRouter.shared.broadcast(shortcutItem.type)
    }
}
