//
//  UIView-FadeIn.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension UIView {
    /// Animates a UIView with a specific delay and duration.
    func fade(to alpha: CGFloat, delay: TimeInterval = 0, duration: TimeInterval, then completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            self.alpha = alpha
        }, completion: { _ in
            completion?()
        })
    }
}
