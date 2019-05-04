//
//  RearrangeTheLinesViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The view controller that handles Rearrange the Lines practice activities.
class RearrangeTheLinesViewController: UIViewController, Storyboarded, PracticingViewController {
    var coordinator: (Skippable & AnswerHandling)? {
        didSet {
            configureNavigation()
        }
    }

    var practiceType = "rearrange-the-lines"

    @IBOutlet var prompt: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var answerButton: UIButton!

    /// Handles our table view data, while rearranging the user's code.
    var dataSource: RearrangeTheLinesDataSource!

    /// The current question they are solving, along with hints and solutions.
    var practiceData: RearrangeTheLinesPractice!

    /// Lets us track how far the user is through their current practice/challenge session.
    var questionNumber = 1

    /// Run all our navigation bar code super early to avoid bad animations on iPhone
    func configureNavigation() {
        title = "Rearrange the Lines" + (coordinator?.titleSuffix(for: self) ?? "")
        navigationItem.largeTitleDisplayMode = .never
        extendedLayoutIncludesOpaqueBars = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skip))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hint", style: .plain, target: self, action: #selector(hint))
    }

    /// Configures the UI with the correct content for our current activity.
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")
        assert(practiceData != nil, "You must assign some practice data before presenting this view controller.")

        dataSource = RearrangeTheLinesDataSource(practiceData: practiceData)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.isEditing = true

        prompt.attributedText = practiceData.question.fromSimpleHTML()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // warn users there might be more cells to scroll through
        tableView.flashScrollIndicators()
    }

    @objc func hint() {
        showAlert(body: practiceData.hint)
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

            navigationItem.leftBarButtonItem?.isEnabled = false
            answerButton.setTitle("CONTINUE", for: .normal)

            if practiceData.answerIsCorrect(dataSource.currentCode) {
                answerButton.correctAnswer()
            } else {
                answerButton.wrongAnswer()
            }
        }
    }
}
