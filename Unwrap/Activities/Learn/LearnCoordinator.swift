//
//  LearnCoordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import AVKit
import SwiftEntryKit
import UIKit

/// Manages everything launched from the Learn tab in the app.
class LearnCoordinator: Coordinator, Awarding, Skippable, AlertHandling, AnswerHandling, UISplitViewControllerDelegate {
    var splitViewController = UISplitViewController()
    var primaryNavigationController = CoordinatedNavigationController()
    var activeStudyReview: StudyReview!

    /// Whether or not the user can have multiple attempts at questions
    let retriesAllowed = true

    init() {
        // Set up the master view controller
        primaryNavigationController.navigationBar.prefersLargeTitles = true
        primaryNavigationController.coordinator = self

        let viewController = LearnViewController(style: .plain)
        viewController.coordinator = self
        primaryNavigationController.viewControllers = [viewController]

        // Set up the detail view controller
        let detailNavigationController = CoordinatedNavigationController(rootViewController: studyViewController(for: "Variables"))

        splitViewController.viewControllers = [primaryNavigationController, detailNavigationController]
        splitViewController.tabBarItem = UITabBarItem(title: "Learn", image: UIImage(bundleName: "Learn"), tag: 1)

        // make this split view controller behave sensibly on iPad
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.delegate = SplitViewControllerDelegate.shared
    }

    /// Shows the list of common Swift terms
    func showGlossary() {
        let vc = GlossaryViewController(style: .plain)
        primaryNavigationController.pushViewController(vc, animated: true)
    }

    /// Triggered when we already have a study view controller configured and ready to go, so we just show it.
    func startStudying(using viewController: UIViewController) {
        let detailNav = CoordinatedNavigationController(rootViewController: viewController)
        splitViewController.showDetailViewController(detailNav, sender: self)
    }

    /// Creates and configures – but does not show! – a study view controller for a specific chapter. This might be called when the user tapped a chapter, or when they 3D touch one.
    func studyViewController(for title: String) -> StudyViewController {
        activeStudyReview = StudyReview.review(for: title.bundleName)

        let studyViewController = StudyViewController()
        studyViewController.coordinator = self
        studyViewController.hidesBottomBarWhenPushed = true
        studyViewController.title = title
        studyViewController.chapter = title.bundleName

        return studyViewController
    }

    /// Creates, configures, and presents a study view controller for a specific chapter.
    func startStudying(title: String) {
        let viewController = studyViewController(for: title)
        startStudying(using: viewController)
    }

    /// Displays a full-screen video player when the user taps the image at the top of a study view controller.
    func playStudyVideo() {
        guard let videoURL = Bundle.main.url(forResource: activeStudyReview.title.bundleName, withExtension: "mp4") else { return }
        let player = AVPlayer(url: videoURL)

        // It would be lovely to make a custom subclass of
        // AVPlayerViewController that is always landscape,
        // but that causes our text view scroll position
        // to jump down for some reason. Yay.
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        player.play()

        splitViewController.present(playerViewController, animated: true)
    }

    /// When we finish studying, we either move to the postscript or we start reviewing.
    @objc func finishedStudying() {
        if activeStudyReview.postscript.isEmpty {
            beginReview()
        } else {
            showPostscript()
        }
    }

    /// Shows the correct review screen for the current chapter.
    func beginReview() {
        assert(activeStudyReview.reviewType == "multipleSelection" || activeStudyReview.reviewType == "singleSelection", "Unknown review type for study review: \(activeStudyReview.reviewType).")

        if activeStudyReview.reviewType == "multipleSelection" {
            let viewController = MultipleSelectReviewViewController.instantiate()
            viewController.coordinator = self
            viewController.review = activeStudyReview
            viewController.sectionName = activeStudyReview.title.bundleName

            let detailNav = CoordinatedNavigationController(rootViewController: viewController)
            splitViewController.showDetailViewController(detailNav, sender: self)
        } else {
            let viewController = SingleSelectReviewViewController.instantiate()
            viewController.coordinator = self
            viewController.review = activeStudyReview

            let detailNav = CoordinatedNavigationController(rootViewController: viewController)
            splitViewController.showDetailViewController(detailNav, sender: self)
        }
    }

    /// Shows a short message after the user has finished reading a chapter, but before review starts.
    func showPostscript() {
        assert(activeStudyReview.postscript.isEmpty == false, "Attempting to show empty post script.")

        let alert = AlertViewController.instantiate()
        alert.coordinator = self
        alert.title = activeStudyReview.title
        alert.alertType = .postscript
        alert.body = activeStudyReview.postscript.fromSimpleHTML()
        alert.presentAsAlert()
    }

    /// This will get called when the postscript has been dismissed, so we can move on to review.
    func alertDismissed(type: AlertType) {
        SwiftEntryKit.dismiss {
            if type == .postscript {
                self.beginReview()
            }
        }
    }

    /// This is called when the user has submitted an answer to a review view controller. If it's a single selection view controller then we either finish reviewing or show another single selection view controller; if it's a multiple selection view controller then we're finished reviewing because that's only one screen.
    func answerSubmitted(from reviewViewController: UIViewController, wasCorrect: Bool) {
        if let single = reviewViewController as? SingleSelectReviewViewController {
            if single.questionNumber == 8 {
                // This is a single selection review and this is the final question, so we're done reviewing.
                finishedReviewing()
            } else {
                // This is a single selection review but we haven't shown them all yet, so show another in the sequence.
                let viewController = SingleSelectReviewViewController.instantiate()
                viewController.coordinator = self
                viewController.review = single.review
                viewController.answers = single.answers
                viewController.questionNumber = single.questionNumber + 1

                reviewViewController.navigationController?.pushViewController(viewController, animated: false)
            }
        } else {
            /// this is a multiple selection review, so we only ever show one – we're done reviewing.
            finishedReviewing()
        }
    }

    /// Called when the user doesn't want to continue reviewing this chapter, so we either award points or bail out.
    func skipReviewing() {
        let sectionName = activeStudyReview.title.bundleName

        if User.current.hasLearned(sectionName) {
            // Exit back to the main chapter list.
            award(points: 0, for: .review(chapter: sectionName))
        } else {
            // They should get points for at least reading the chapter, so present the awards screen.
            award(points: User.pointsForLearning, for: .learn(chapter: sectionName))
        }
    }

    /// Called when the user has completed reviewing a chapter.
    func finishedReviewing() {
        let sectionName = activeStudyReview.title.bundleName

        if User.current.hasReviewed(sectionName) {
            // They already reviewed this chapter, so don't award them more points.
            award(points: 0, for: .review(chapter: sectionName))
        } else {
            // This is their first time reviewing this chapter, so award them points.
            var pointsToAward = User.pointsForReviewing

            // if the user is reading this for the first time, we also need to give them bonus points for reading it
            if !User.current.hasLearned(sectionName) {
                pointsToAward += User.pointsForLearning
            }

            award(points: pointsToAward, for: .review(chapter: sectionName))
        }
    }

    // Single select reviews come in groups of eight.
    func titleSuffix(for item: Sequenced) -> String {
        return " (\(item.questionNumber)/8)"
    }

    func show(url: URL) {
        let viewController = WebViewController(url: url)
        let detailNav = CoordinatedNavigationController(rootViewController: viewController)
        splitViewController.showDetailViewController(detailNav, sender: self)
    }
}
