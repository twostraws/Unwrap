//
//  ChallengesCoordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import SwiftEntryKit
import UIKit

/// Manages everything launched from the Challenges tab in the app.
class ChallengesCoordinator: Coordinator, Awarding, Skippable, AnswerHandling {
    var navigationController: CoordinatedNavigationController

    /// The list of practice activities in the current challenge.
    var questions = [PracticeActivity.Type]()

    /// The user's cumulative score for their current challenge.
    var currentScore = 0

    /// The user may skip up to three times in each challenge.
    var skipsRemaining = 3

    /// Whether or not the user can have multiple attempts at questions
    let retriesAllowed = false

    init(navigationController: CoordinatedNavigationController = CoordinatedNavigationController()) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.coordinator = self

        let viewController = ChallengesViewController.instantiate()
        viewController.tabBarItem = UITabBarItem(title: "Challenges", image: UIImage(bundleName: "Challenges"), tag: 3)
        viewController.coordinator = self
        navigationController.viewControllers = [viewController]
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
            var viewController = currentQuestion.instantiate()
            viewController.coordinator = self
            viewController.questionNumber = 10 - questions.count
            navigationController.pushViewController(viewController, animated: true)
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
            self.returnToStart(pointsAwarded: false)
        }

        let continueAction = UIAlertAction(title: "Continue", style: .cancel)

        if skipsRemaining > 0 {
            // Only add the skip action if they still have skips available.
            alert.addAction(skipAction)
        }

        alert.addAction(quitAction)
        alert.addAction(continueAction)
        navigationController.present(alert, animated: true)
    }

    /// Called from the main Challenges table view so that users can share their scores with friends online.
    func shareScore(_ challenge: ChallengeResult) {
        let text = "I scored \(challenge.score) in Unwrap's daily challenge for \(challenge.date.formatted). Download it here: \(Unwrap.appURL)"

        let alert = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        navigationController.present(alert, animated: true)
    }
}
