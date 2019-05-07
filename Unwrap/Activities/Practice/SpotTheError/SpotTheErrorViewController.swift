//
//  SpotTheErrorViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The view controller that handles Spot the Error practice activities.
class SpotTheErrorViewController: UIViewController, Storyboarded, PracticingViewController {
    var coordinator: (Skippable & AnswerHandling)? {
        didSet {
            configureNavigation()
        }
    }

    var practiceType = "spot-the-error"

    @IBOutlet var prompt: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var answerButton: UIButton!

    /// Handles our table view data.
    var dataSource: SpotTheErrorDataSource!

    /// The current question they are solving, along with hints and solutions.
    var practiceData: SpotTheErrorPractice!

    /// Lets us track how far the user is through their current practice/challenge session.
    var questionNumber = 1

    /// Run all our navigation bar code super early to avoid bad animations on iPhone
    func configureNavigation() {
        title = "Spot the Error" + (coordinator?.titleSuffix(for: self) ?? "")
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

        dataSource = SpotTheErrorDataSource(practiceData: practiceData)
        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        prompt.attributedText = practiceData.question.fromSimpleHTML()
    }

    /// Shows extra explanation to users to help them understand where the error is.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showFirstTimeAlert(name: "SpotTheError", title: "Tip", message: "You should mentally run the code from top to bottom, meaning that if line 3 says an integer should be returned and line 10 tries to return a string, line 10 is the wrong one.")

        // warn users there might be more cells to scroll through
        tableView.flashScrollIndicators()
    }

    @objc func hint() {
        showAlert(body: practiceData.hint)
    }

    @objc func skip() {
        coordinator?.skipPracticing()
    }

    /// Triggered when the user taps a line. They can't submit the answer until a line has been chosen.
    func selectionChanged() {
        if let number = dataSource.selectedAnswer {
            answerButton.setTitle("ERROR ON LINE \(number + 1)", for: .normal)
            answerButton.backgroundColor = UIColor(bundleName: "Primary")
            answerButton.isEnabled = true
        } else {
            answerButton.setTitle("SELECT A LINE", for: .normal)
            answerButton.backgroundColor = UIColor(bundleName: "PrimaryDisabled")
            answerButton.isEnabled = false
        }
    }

    /// Check whether the user's answer was correct and either update the UI to reflect their answer or move on.
    @IBAction func checkAnswer(_ sender: Any) {
        if dataSource.isShowingAnswers {
            coordinator?.answerSubmitted(from: self, wasCorrect: dataSource.isUserCorrect)
        } else {
            dataSource.isShowingAnswers = true

            // make sure we highlight the actual bad line
            let correct = IndexPath(row: practiceData.lineNumber, section: 0)
            tableView.scrollToRow(at: correct, at: .none, animated: true)
            tableView.reloadData()

            navigationItem.leftBarButtonItem?.isEnabled = false
            answerButton.setTitle("CONTINUE", for: .normal)

            if dataSource.isUserCorrect {
                answerButton.correctAnswer()
            } else {
                answerButton.wrongAnswer()
            }
        }
    }
}
