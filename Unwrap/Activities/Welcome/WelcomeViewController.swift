//
//  ViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import SwiftEntryKit
import UIKit

/// The first run screen for the app, explaining the basics of how things work.
class WelcomeViewController: UIViewController, Storyboarded {
    /// Triggered when the user taps Start Tour
    @IBAction func startTour(_ sender: Any) {
        guard let view = self.view as? WelcomeView else {
            fatalError("WelcomeViewController doesn't have a WelcomeView as its view.")
        }

        view.showTour()
    }

    /// Triggered when the user wants to end the tour at any point.
    @IBAction func skipTour(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
}
