//
//  PracticeCoordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages everything launched from the Practice tab in the app.
class PracticeCoordinator: Coordinator, Awarding, Skippable, AnswerHandling {
    var navigationController: CoordinatedNavigationController

    /// Stores whichever activity the user is currently taking, so that we can make new instances of it when working through a practice sequence.
    var currentActivity: PracticeActivity.Type?

    /// Stores the user's current score for a practice sequence. Gets reset to 0 when a new practice session starts.
    var currentScore = 0

    /// Whether or not the user can have multiple attempts at questions
    let retriesAllowed = true

    init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController()) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.coordinator = self

        let viewController = PracticeViewController.instantiate()
        viewController.tabBarItem = UITabBarItem(title: "Practice", image: UIImage(bundleName: "Practice"), tag: 2)
        viewController.coordinator = self
        navigationController.viewControllers = [viewController]
    }

    /// Called when the user wants to start practicing something. We either start it immediately, or show an alert refusing access if they haven't completed the required learn chapter.
    func startPracticing(_ activity: PracticeActivity.Type) -> Bool {
        if activity.isLocked {
            // They can't access this practice activity yet.
            let alert = UIAlertController(title: "Activity Locked", message: "You need to complete the chapter \"\(activity.lockedUntil)\" before you can practice this.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            navigationController.present(alert, animated: true)
            return false
        } else {
            // They can access this activity, so clear our state and begin immediately.
            currentActivity = activity
            currentScore = 0

            var viewController = activity.instantiate()
            viewController.coordinator = self
            navigationController.pushViewController(viewController, animated: true)

            return true
        }
    }

    /// Called when the user has submitted an answer from a practice question.
    func answerSubmitted(from: UIViewController, wasCorrect: Bool) {
        guard let practicingViewController = from as? PracticingViewController else {
            fatalError("Unknown view controller trying to submit a practice answer.")
        }

        if wasCorrect {
            // The user was correct, so add some points to their cumulative score.
            currentScore += User.pointsForPracticing
        }

        // Practice sessions are limited to 5 questions per type, so check if it's time to end the session.
        if practicingViewController.questionNumber == 5 {
            finishedPracticing(type: practicingViewController.practiceType)
        } else {
            // We're not finished yet, so make a fresh instance of our practice type, move its question number along one, then show it.
            guard var viewController = currentActivity?.instantiate() else {
                fatalError("Trying to instantiate an empty practice activity.")
            }

            viewController.questionNumber = practicingViewController.questionNumber + 1
            viewController.coordinator = self

            navigationController.pushViewController(viewController, animated: true)
        }
    }

    /// Called when the user has completed a practice session successfully, so we should award some points.
    func finishedPracticing(type: String) {
        award(points: currentScore, for: .practice(type: type))
    }

    /// Called when the user has requested to exit the current practice session, so we should terminate it without awarding points.
    func skipPracticing() {
        returnToStart(pointsAwarded: false)
    }

    /// Add something like "(2/5)" to the title of each practice activity.
    func titleSuffix(for item: Sequenced) -> String {
        return " (\(item.questionNumber)/5)"
    }
}
