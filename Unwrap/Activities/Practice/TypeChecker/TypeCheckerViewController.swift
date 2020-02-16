//
//  TypeCheckerViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The view controller that handles Type Checker practice activities.
class TypeCheckerViewController: UIViewController, Storyboarded, PracticingViewController {
    var coordinator: (Skippable & AnswerHandling)? {
        didSet {
            configureNavigation()
        }
    }

    var practiceType = "type-practice"

    @IBOutlet var prompt: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var answerButton: UIButton!

    /// Handles our table view data.
    var dataSource: TypeCheckerDataSource!

    /// The current question they are solving, along with hints and solutions.
    var review: TypeCheckerPractice!

    /// Lets us track how far the user is through their current practice/challenge session.
    var questionNumber = 1

    /// Run all our navigation bar code super early to avoid bad animations on iPhone
    func configureNavigation() {
        title = "Type Practice" + (coordinator?.titleSuffix(for: self) ?? "")
        navigationItem.largeTitleDisplayMode = .never
        extendedLayoutIncludesOpaqueBars = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skip))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hint", style: .plain, target: self, action: #selector(hint))
    }

    /// Configures the UI with the correct content for our current activity.
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        // Users need to be able to check all the rows they want, so our data source is used for the table view's data source and delegate.
        dataSource = TypeCheckerDataSource(review: review)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.isEditing = true

        prompt.attributedText = review.question.fromSimpleHTML()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // warn users there might be more cells to scroll through
        tableView.flashScrollIndicators()
    }

    @objc func hint() {
        showAlert(body: "Any code without an explicit type will rely on type inference instead.")
    }

    @objc func skip() {
        coordinator?.skipPracticing()
    }

    /// Check whether the user's answer was correct and either update the UI to reflect their answer or move on.
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
