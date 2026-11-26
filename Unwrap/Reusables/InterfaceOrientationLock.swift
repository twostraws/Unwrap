//
//  InterfaceOrientationLock.swift
//  Unwrap
//

import SwiftUI
import UIKit

/// Decides which orientations the app may rotate to.
///
/// iPhone stays in portrait unless a view asks for landscape, such as full-screen video. iPad is never
/// restricted, so nothing here applies to it.
enum InterfaceOrientationLock {
    /// Whether iPhone is currently allowed to rotate into landscape.
    private(set) static var allowsLandscape = false

    /// The orientations the app delegate should report to the system right now.
    static var supportedOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            .all
        } else if allowsLandscape {
            .allButUpsideDown
        } else {
            .portrait
        }
    }

    /// Changes whether iPhone may rotate into landscape, rotating back to portrait when that is taken away.
    static func setAllowsLandscape(_ newValue: Bool) {
        guard UIDevice.current.userInterfaceIdiom != .pad else { return }
        guard allowsLandscape != newValue else { return }
        allowsLandscape = newValue

        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            // The system only asks again once the controllers on screen say their answer has changed.
            for window in scene.windows {
                var controller = window.rootViewController

                while let current = controller {
                    current.setNeedsUpdateOfSupportedInterfaceOrientations()
                    controller = current.presentedViewController
                }
            }

            if newValue == false {
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }
}

extension View {
    /// Lets iPhone rotate into landscape for as long as this view is on screen.
    func allowsLandscape() -> some View {
        self
            .onAppear {
                InterfaceOrientationLock.setAllowsLandscape(true)
            }
            .onDisappear {
                InterfaceOrientationLock.setAllowsLandscape(false)
            }
    }
}
