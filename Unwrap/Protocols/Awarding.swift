//
//  AwardCoordinating.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A protocol for parts of the app that can award points. Conforming types shouldn't provide their own implementations of any methods.
protocol Awarding: Coordinator { }

extension Awarding {
    /// Moves us from the current view controller to the awards view controller, all configured to award some points.
    func award(points: Int, for type: AwardType) {
        let viewController = AwardPointsViewController.instantiate()

        viewController.coordinator = self
        viewController.awardType = type
        viewController.pointsToAward = points
        viewController.modalTransitionStyle = .crossDissolve

        if #available(iOS 13, *) {
            // make sure this view controller takes up the full screen rather than being swipe to dismiss.
            viewController.isModalInPresentation = true
            viewController.modalPresentationStyle = .fullScreen
        }

        if splitViewController.isCollapsed {
            // As soon as the award view controller is shown, get back to the root of our navigation stack.
            splitViewController.present(viewController, animated: true) {
                self.returnToStart()
            }
        } else {
            // Show the awards screen alongside the master view controller.
            splitViewController.showDetailViewController(viewController, sender: self)
        }
    }

    /// Hides the awards view controller.
    func finishedAwards() {
        splitViewController.dismiss(animated: true)
    }

    /// Returns to the root of our navigation stack.
    func returnToStart(activityType: Unwrap.ActivityType = .practice) {
        splitViewController.popToRootViewController()

        if splitViewController.isCollapsed == false {
            let viewController = PleaseSelectViewController.instantiate()
            viewController.selectionMode = activityType
            splitViewController.showDetailViewController(viewController, sender: self)
        }
    }
}
