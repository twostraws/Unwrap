//
//  SceneDelegate.swift
//  Unwrap
//
//  Created by Paul Hudson on 13/07/2026.
//  Copyright © 2026 Hacking with Swift.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard ProcessInfo.processInfo.environment["IS_TESTING"] != "1" else {
            return
        }

        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let tabBarController = MainTabBarController()
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()

        if let shortcutItem = connectionOptions.shortcutItem {
            tabBarController.loadViewIfNeeded()
            tabBarController.handle(shortcutItem: shortcutItem)
        }
    }

    func windowScene(_: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let tabBarController = window?.rootViewController as? MainTabBarController else {
            completionHandler(false)
            return
        }

        completionHandler(tabBarController.handle(shortcutItem: shortcutItem))
    }
}
