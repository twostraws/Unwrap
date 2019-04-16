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
    var coordinator: (Skippable & AnswerHandling)?
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

    /// Configures the UI with the correct content for our current activity.
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        title = "Type Practice" + (coordinator?.titleSuffix(for: self) ?? "")
        navigationItem.largeTitleDisplayMode = .never

        // Users need to be able to check all the rows they want, so our data source is used for the table view's data source and delegate.
        dataSource = TypeCheckerDataSource(review: review)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.isEditing = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skip))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hint", style: .plain, target: self, action: #selector(hint))

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
}
