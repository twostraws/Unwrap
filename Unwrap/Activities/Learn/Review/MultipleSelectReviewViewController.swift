//
//  MultipleSelectReviewViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class MultipleSelectReviewViewController: ReviewViewController, Storyboarded {
    @IBOutlet var prompt: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var answerButton: UIButton!

    var dataSource: MultipleSelectReviewDataSource!

    /// Run all our navigation bar code super early to avoid bad animations on iPhone
    override func configureNavigation() {
        super.configureNavigation()
        title = getTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = MultipleSelectReviewDataSource(review: review)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.isEditing = true

        prompt.attributedText = review.question.fromSimpleHTML()
    }

    func getTitle() -> String {
        return "Review"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // warn users there might be more cells to scroll through
        tableView.flashScrollIndicators()
    }

    @IBAction func checkAnswer(_ sender: Any) {
        if dataSource.isShowingAnswers {
            coordinator?.answerSubmitted(from: self, wasCorrect: dataSource.isUserCorrect)
        } else {
            dataSource.isShowingAnswers = true
            tableView.reloadData()

            answerButton.setTitle("CONTINUE", for: .normal)
            navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }

    // If we dynamically changed between light and dark mode while the app was running, make sure we refresh our layout to reflect the theme.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            tableView.reloadDataSavingSelections()
        }
    }
}
