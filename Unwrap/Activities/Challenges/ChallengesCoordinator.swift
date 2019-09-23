//
//  ChallengesCoordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import SwiftEntryKit
import UIKit

/// Manages everything launched from the Challenges tab in the app.
class ChallengesCoordinator: Coordinator, Awarding, Skippable, AnswerHandling {
    var splitViewController = UISplitViewController()
    var primaryNavigationController = CoordinatedNavigationController()

    /// The list of practice activities in the current challenge.
    var questions = [PracticeActivity.Type]()

    /// The user's cumulative score for their current challenge.
    var currentScore = 0

    /// The user may skip up to three times in each challenge.
    var skipsRemaining = 3

    /// Whether or not the user can have multiple attempts at questions
    let retriesAllowed = false

    init() {
        // Set up the master view controller
        primaryNavigationController.navigationBar.prefersLargeTitles = true
        primaryNavigationController.coordinator = self

        let viewController = ChallengesViewController(style: .grouped)
        viewController.coordinator = self
        primaryNavigationController.viewControllers = [viewController]

        // Set up the detail view controller
        let detailViewController = PleaseSelectViewController.instantiate()
        detailViewController.selectionMode = .challenges

        splitViewController.viewControllers = [primaryNavigationController, detailViewController]
        splitViewController.tabBarItem = UITabBarItem(title: "Challenges", image: UIImage(bundleName: "Challenges"), tag: 3)

        // make this split view controller behave sensibly on iPad
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.delegate = SplitViewControllerDelegate.shared
    }

    /// Called when the user starts their daily challenge – removes all the activities, clears their score, and resets the skips they have remaining.
    func startChallenge() {
        currentScore = 0
        skipsRemaining = 3

        // Each challenge is made up of specific question types; some are more heavily weighted
        // because they have significantly more material to work with and are less likely
        // to produce duplicate questions
        let possibleActivities: [PracticeActivity.Type] = [
            SpotTheErrorPractice.self, SpotTheErrorPractice.self, SpotTheErrorPractice.self,
            RearrangeTheLinesPractice.self, RearrangeTheLinesPractice.self,
            TapToCodePractice.self, TapToCodePractice.self,
            PredictTheOutputPractice.self,
            FreeCodingPractice.self,
            TypeCheckerPractice.self
        ]

        // shuffle up the 10 questions to produce our challenge
        questions = possibleActivities.shuffled()

        // Kick off the first activity.
        askQuestion()
    }

    /// Moves the current challenge to the next question, or ends it if there are no more questions.
    func askQuestion() {
        if let currentQuestion = questions.popLast() {
            let viewController = currentQuestion.instantiate()
            viewController.questionNumber = 10 - questions.count
            viewController.coordinator = self

            let detailNav = CoordinatedNavigationController(rootViewController: viewController)
            splitViewController.showDetailViewController(detailNav, sender: self)
        } else {
            award(points: currentScore, for: .challenge)
        }
    }

    /// If someone skips reviewing, just move on. Note: this isn't currently possible, because chapter reviews aren't incorporated into challenges.
    func skipReviewing() {
        addSkip { [weak self] in
            self?.askQuestion()
        }
    }

    /// If someone skips practicing, just move on if possible.
    func skipPracticing() {
        addSkip { [weak self] in
            self?.askQuestion()
        }
    }

    /// Called when the user has submitted an answer, so we need to move on. If it's correct we can add some points to their score.
    func answerSubmitted(from: UIViewController, wasCorrect: Bool) {
        if wasCorrect {
            currentScore += 50
        }

        askQuestion()
    }

    /// Add something like "(2/10)" to the title of each practice activity.
    func titleSuffix(for item: Sequenced) -> String {
        return " (\(item.questionNumber)/10)"
    }

    /// Generates a UIAlertController that lets users skip the current challenge question (if they have skips remaining) or exit the whole challenge.
    func addSkip(then nextAction: @escaping () -> Void) {
        let alert = UIAlertController(title: "Are you sure?", message: "You can skip only three questions during a challenge, and if you quit you won't be able to take a daily challenge again until tomorrow.\n\nYou have \(skipsRemaining.spelledOut) remaining.", preferredStyle: .alert)

        let skipAction = UIAlertAction(title: "Skip Question", style: .default) { _ in
            self.skipsRemaining -= 1
            nextAction()
        }

        let quitAction = UIAlertAction(title: "End Challenge", style: .destructive) { _ in
            // immediately score today's challenge as zero so they can't retake
            User.current.completedChallenge(score: 0)

            // then exit the challenge
            self.returnToStart(activityType: .challenges)
        }

        let continueAction = UIAlertAction(title: "Continue", style: .cancel)

        if skipsRemaining > 0 {
            // Only add the skip action if they still have skips available.
            alert.addAction(skipAction)
        }

        alert.addAction(quitAction)
        alert.addAction(continueAction)
        splitViewController.present(alert, animated: true)
    }

    /// Called from the main Challenges table view so that users can share their scores with friends online.
    func shareScore(_ challenge: ChallengeResult, from sourceRect: CGRect) {
        let text = "I scored \(challenge.score) in Unwrap's daily challenge for \(challenge.date.formatted). Download it here: \(Unwrap.appURL) (via @twostraws)"

        let alert = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        // if we're on iPad we'll anchor this thing to the table view cell they tapped
        if let popOver = alert.popoverPresentationController {
            popOver.sourceView = primaryNavigationController.topViewController?.view
            popOver.sourceRect = sourceRect
        }

        splitViewController.present(alert, animated: true)
    }

    /// When using split view controllers, completing a challenge results in the awards screen staying visible in the detail view controller until the app finally exits. To avoid that scenario, this method resets the detail view controller.
    func resetDetailViewController() {
        guard splitViewController.isCollapsed == false else { return }
        guard splitViewController.viewControllers.last is AwardPointsViewController else { return }

        let newDetail = PleaseSelectViewController.instantiate()
        newDetail.selectionMode = .challenges
        splitViewController.viewControllers = [splitViewController.viewControllers[0], newDetail]
    }
}
