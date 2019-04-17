//
//  WelcomeView.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class WelcomeView: GradientView {
    @IBOutlet var logo: ShapeView!
    @IBOutlet var welcome: UILabel!
    @IBOutlet var startTour: UIButton!
    @IBOutlet var skipTour: UIButton!
    @IBOutlet var tourContainer: UIView!

    /// Set up the animation that draws our logo and brings in our two buttons smoothly.
    override func didMoveToSuperview() {
        logo.path = UIBezierPath.logo
        logo.draw(delay: 0.5, duration: 2, keyFrameValues: [0, 0.129, 0.373, 0.58, 0.928, 1.0])

        logo.alpha = 0
        welcome.alpha = 0
        startTour.alpha = 0
        skipTour.alpha = 0

        logo.fade(to: 1.0, duration: 2.5)
        welcome.fade(to: 1.0, delay: 1.0, duration: 1.5)
        startTour.fade(to: 1.0, delay: 1.5, duration: 1.0)
        skipTour.fade(to: 1.0, delay: 2.0, duration: 0.5)
    }

    /// Replaces most of the UI with the scrolling page view controller.
    func showTour() {
        logo.fade(to: 0, duration: 0.5)
        welcome.fade(to: 0, duration: 0.5)
        startTour.fade(to: 0, duration: 0.5)

        tourContainer.fade(to: 1, delay: 0.5, duration: 0.5)
    }
}
