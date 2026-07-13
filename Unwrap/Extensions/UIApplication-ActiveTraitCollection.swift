//
//  UIApplication-ActiveTraitCollection.swift
//  Unwrap
//
//  Created by Paul Hudson on 23/09/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

extension UIApplication {
    /** Attempts to return the active trait collection for the foreground scene's key window, or an empty trait collection otherwise. This should only be used for system-wide settings – dark mode, scale, etc.
     */
    static var activeTraitCollection: UITraitCollection {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let windowScene = windowScenes.first { $0.activationState == .foregroundActive }
            ?? windowScenes.first { $0.activationState == .foregroundInactive }
            ?? windowScenes.first
        let window = windowScene?.windows.first { $0.isKeyWindow } ?? windowScene?.windows.first

        if let activeTraits = window?.traitCollection {
            return activeTraits
        } else {
            return UITraitCollection()
        }
    }
}
