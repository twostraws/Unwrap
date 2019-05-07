//
//  ReviewPractice.swift
//  Unwrap
//
//  Created by Michael Charland on 2019-02-03.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

/// The Free Coding practice activity. Shows users a question and asks them to write Swift code to solve the problem.
struct ReviewPractice: PracticeActivity {

    static let name = "Review"
    static let subtitle = "Go over questions you've already learned"
    static let lockedUntil = "Variables"
    static let icon = UIImage(bundleName: "Practice-Review")

    /// Creates a view controller configured with a Review Practice activity.
    static func instantiate() -> UIViewController & PracticingViewController {

        // Create a list of all the sections that have been completed.
        var completedSections = [String]()
        for chapter in Unwrap.chapters {
            for section in chapter.sections {
                let sectionName = section.bundleName
                if User.current.ratingForSection(sectionName) > 0 {
                    completedSections.append(sectionName)
                }
            }
        }

        // Randomly pick a section to ask a question for.
        let section = completedSections[Int.random(in: 0 ..< completedSections.count)]

        let review = StudyReview.review(for: section)

        if review.reviewType == "multipleSelection" {
            let viewController = ReviewMultipleSelectViewController.instantiate()
            viewController.review = review
            return viewController
        }
        let viewController = ReviewSingleSelectViewController.instantiate()
        viewController.review = review
        return viewController

    }
}
