//
//  PracticeCoordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages everything launched from the Practice tab in the app.
class PracticeCoordinator: Coordinator, Awarding, Skippable, AnswerHandling, AlertShowing {
    var splitViewController = PortraitSplitViewController()
    var primaryNavigationController = CoordinatedNavigationController()

    var practiceViewController = PracticeViewController(style: .plain)

    /// Stores whichever activity the user is currently taking, so that we can make new instances of it when working through a practice sequence.
    var currentActivity: PracticeActivity.Type?

    /// Stores the user's current score for a practice sequence. Gets reset to 0 when a new practice session starts.
    var currentScore = 0

    /// Whether or not the user can have multiple attempts at questions
    let retriesAllowed = true

    init() {
        // Set up the master view controller
        primaryNavigationController.navigationBar.prefersLargeTitles = true
        primaryNavigationController.coordinator = self

        practiceViewController.coordinator = self
        primaryNavigationController.viewControllers = [practiceViewController]

        // Set up the detail view controller
        splitViewController.viewControllers = [primaryNavigationController, PleaseSelectViewController.instantiate()]
        splitViewController.tabBarItem = UITabBarItem(title: "Practice", image: UIImage(bundleName: "Practice"), tag: 2)

        // make this split view controller behave sensibly on iPad
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.delegate = SplitViewControllerDelegate.shared
    }

    /// Called when the user wants to start practicing something. We either start it immediately, or show an alert refusing access if they haven't completed the required learn chapter.
    func startPracticing(_ activity: PracticeActivity.Type) -> Bool {
        if activity.isLocked {
            // They can't access this practice activity yet.
            showAlert(title: "Activity Locked", body: "You need to complete the chapter \"\(activity.lockedUntil)\" before you can practice this.")

            if splitViewController.isCollapsed == false {
                splitViewController.showDetailViewController(PleaseSelectViewController.instantiate(), sender: self)
            }

            return false
        } else {
            // They can access this activity, so clear our state and begin immediately.
            currentActivity = activity
            currentScore = 0

            let viewController = activity.instantiate()
            viewController.coordinator = self

            let detailNav = CoordinatedNavigationController(rootViewController: viewController)
            splitViewController.showDetailViewController(detailNav, sender: self)

            return true
        }
    }

    /// Called when the user has submitted an answer from a practice question.
    func answerSubmitted(from viewController: UIViewController, wasCorrect: Bool) {
        guard let practicingViewController = viewController as? PracticingViewController else {
            fatalError("Unknown view controller trying to submit a practice answer.")
        }

        if wasCorrect {
            // The user was correct, so add some points to their cumulative score.
            currentScore += User.pointsForPracticing
        }

        // Practice sessions are limited to 10 questions per type, so check if it's time to end the session.
        if practicingViewController.questionNumber == 10 {
            finishedPracticing(type: practicingViewController.practiceType)
        } else {
            // We're not finished yet, so make a fresh instance of our practice type, move its question number along one, then show it.
            guard let viewController = currentActivity?.instantiate() else {
                fatalError("Trying to instantiate an empty practice activity.")
            }

            viewController.questionNumber = practicingViewController.questionNumber + 1
            viewController.coordinator = self

            practicingViewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    /// Called when the user has completed a practice session successfully, so we should award some points.
    func finishedPracticing(type: String) {
        award(points: currentScore, for: .practice(type: type))
    }

    /// Called when the user has requested to exit the current practice session, so we should terminate it without awarding points.
    func skipPracticing() {
        practiceViewController.resetTableView()
        returnToStart()
    }

    /// Add something like "(2/10)" to the title of each practice activity.
    func titleSuffix(for item: Sequenced) -> String {
        return " (\(item.questionNumber)/10)"
    }
}
