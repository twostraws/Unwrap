//
//  AwardPointsViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The view controller that handles visually awarding points to users.
class AwardPointsViewController: UIViewController, Storyboarded {
    var coordinator: Awarding? {
        didSet {
            configureNavigation()
        }
    }

    @IBOutlet var statusView: StatusView!
    @IBOutlet var totalPoints: CountingLabel!
    @IBOutlet var earnedPoints: CountingLabel!
    @IBOutlet var tapToContinue: UILabel!

    /// The reason we're giving points to the user: learning, reviewing, practicing, or challenges.
    var awardType = AwardType.challenge

    /// The number of points to award.
    var pointsToAward = 100

    /// The UI design has a blue background, so we need a light status bar style.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// Run all our navigation bar code super early to avoid bad animations on iPhone
    func configureNavigation() {
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")
        extendedLayoutIncludesOpaqueBars = true

        totalPoints.title = "TOTAL"
        earnedPoints.title = "EARNED"

        // Configure the status view so that it looks good on a white background, and can animate past 100% so that we can rank up without the animation going back to the start.
        statusView.useTemplateImages = true
        statusView.strokeColorStart = UIColor(bundleName: "Rank-Start")
        statusView.strokeColorEnd = UIColor(bundleName: "Rank-End")
        statusView.shadowOpacity = 1
        statusView.animatePastEnd = true

        // Configure two of our title/subtitle labels so users can see points moving from one place to another.
        totalPoints.textColor = .white
        earnedPoints.textColor = .white
        totalPoints.attributedText = NSAttributedString.makeTitle("TOTAL", subtitle: User.current.totalPoints.formatted)
        earnedPoints.attributedText = NSAttributedString.makeTitle("EARNED", subtitle: pointsToAward.formatted)

        // If we're on iPad, the "Tap to continue" label should not be shown
        if UIDevice.current.userInterfaceIdiom == .pad {
            tapToContinue.isHidden = true
        }

        // If they scored any points at all, wait a split second then run the animation.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.awardPoints()
        }
    }

    /// Performs the animation of granting points, while also actually performing the grant to the user data.
    func awardPoints() {
        totalPoints.count(start: User.current.totalPoints, end: User.current.totalPoints + pointsToAward)
        earnedPoints.count(start: pointsToAward, end: 0)

        // save that they completed some work
        switch awardType {
        case .learn(let chapter):
            User.current.learnedSection(chapter)

        case .review(let chapter):
            User.current.reviewedSection(chapter)

        case .practice(let type):
            User.current.completedPractice(type, score: pointsToAward)

        case .challenge:
            User.current.completedChallenge(score: pointsToAward)
        }
    }

    /// Go away when the user taps anywhere.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        coordinator?.finishedAwards()
    }
}
