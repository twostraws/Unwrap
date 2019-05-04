//
//  TapToCodeViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The view controller that handles Tap to Code practice activities.
class TapToCodeViewController: UIViewController, Storyboarded, PracticingViewController {
    var coordinator: (Skippable & AnswerHandling)? {
        didSet {
            configureNavigation()
        }
    }

    var practiceType = "tap-to-code"

    @IBOutlet var prompt: UILabel!
    @IBOutlet var existingCode: UILabel!
    @IBOutlet var tapCode: UILabel!
    @IBOutlet var answerButton: UIButton!

    /// The collection view that stores the code components they have used.
    @IBOutlet var usedWordsCollectionView: UsedWordsCollectionView!

    /// The collection view that stores the code components they have not yet used.
    @IBOutlet var allWordsCollectionView: AllWordsCollectionView!

    /// A layout constraint we can activate and deactivate depending on whether we have existing code.
    @IBOutlet var usedWordsToExistingCode: NSLayoutConstraint!

    /// Handles our table view data, which is mostly responsible for all the drag and drop code in UIKit.
    var dataSource: TapToCodeDataSource!

    /// The current question they are solving, along with hints and solutions.
    var practiceData: TapToCodePractice!

    /// Lets us track how far the user is through their current practice/challenge session.
    var questionNumber = 1

    /// Run all our navigation bar code super early to avoid bad animations on iPhone
    func configureNavigation() {
        title = "Tap to Code" + (coordinator?.titleSuffix(for: self) ?? "")
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

        if practiceData.existingCode.isEmpty {
            // Hide the existing code label and disable the collection view constraint that positions it below. This will make Auto Layout rely on a second vertical spacing constraint that positions the collection view relative to the prompt view.
            existingCode.isHidden = true
            usedWordsToExistingCode.isActive = false
        }

        // The data source is responsible for handling most of UIKit's drag and drop functionality.
        dataSource = TapToCodeDataSource(practiceData: practiceData, usedWordsCollectionView: usedWordsCollectionView, allWordsCollectionView: allWordsCollectionView)
        dataSource.delegate = self

        // Perform some shared set up for our collection views: make them both draggable, and use the same data source.
        let collectionViews: [UICollectionView] = [usedWordsCollectionView, allWordsCollectionView]

        for collectionView in collectionViews {
            collectionView.dragDelegate = dataSource
            collectionView.dragInteractionEnabled = true
            collectionView.dataSource = dataSource
            collectionView.delegate = dataSource
        }

        // make the top collection view look a little different, and also support dropping of words.
        usedWordsCollectionView.dropDelegate = dataSource
        usedWordsCollectionView.layer.borderWidth = 0.5
        usedWordsCollectionView.layer.cornerRadius = 10

        // pull the question from the data source because it will have resolved variables
        prompt.attributedText = dataSource.question.fromSimpleHTML()

        // pull the existing code from the data source for the same reason
        existingCode.attributedText = dataSource.existingCode.syntaxHighlighted()
        existingCode.font = Unwrap.codeFont

        // give the answer button the correct initial state
        updateAnswerButton()
    }

    @objc func hint() {
        showAlert(body: "All the code components need to be used somewhere – try rearranging them until you're happy.")
    }

    @objc func skip() {
        coordinator?.skipPracticing()
    }

    // Triggered whenever the number of used words has changed, so we can show or hide the instruction label.
    func usedWordsChanged(to count: Int) {
        UIView.animate(withDuration: 0.2) {
            if count == 0 {
                self.tapCode.alpha = 1
            } else {
                self.tapCode.alpha = 0
            }
        }

        updateAnswerButton()
    }

    // Triggered when all the components are used or not, so we can show the correct prompt.
    func updateAnswerButton() {
        if dataSource.readyToCheck {
            answerButton.setTitle("SUBMIT", for: .normal)
            answerButton.backgroundColor = UIColor(bundleName: "Primary")
            answerButton.isEnabled = true
        } else {
            answerButton.setTitle("USE ALL THE CODE", for: .normal)
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
            usedWordsCollectionView.reloadData()
            navigationItem.leftBarButtonItem?.isEnabled = false

            // Style our button correctly depending on the user's success.
            if dataSource.isUserCorrect {
                answerButton.correctAnswer()
            } else {
                answerButton.wrongAnswer()
            }
        }
    }
}
