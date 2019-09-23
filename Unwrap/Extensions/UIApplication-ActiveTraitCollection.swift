//
//  UIApplication-ActiveTraitCollection.swift
//  Unwrap
//
//  Created by Paul Hudson on 23/09/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

extension UIApplication {
    /** Attempts to return the active trait collection for the first window, or an empty trait collection otherwise. Because this specifically uses the first window for the trait collection, it should only be used for system-wide settings – dark mode, scale, etc.
     */
    static var activeTraitCollection: UITraitCollection {
        if let activeTraits = UIApplication.shared.windows.first?.traitCollection {
            return activeTraits
        } else {
            return UITraitCollection()
        }
    }
}
