//
//  FreeCodingViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//
import Sourceful
import UIKit

/// The view controller that handles Free Coding practice activities.
class FreeCodingViewController: UIViewController, Storyboarded, PracticingViewController {
    var coordinator: (Skippable & AnswerHandling)? {
        didSet {
            configureNavigation()
        }
    }

    var practiceType = "free-coding"

    @IBOutlet var prompt: UILabel!
    @IBOutlet var textView: SyntaxTextView!
    @IBOutlet var answerButton: UIButton!

    /// The current question they are solving, along with hints and solutions.
    var practiceData: FreeCodingPractice!

    /// Set to true when the user has selected an answer.
    var isShowingAnswer = false

    /// Lets us track how far the user is through their current practice/challenge session.
    var questionNumber = 1

    /// A lexer to highlight our source code.
    let lexer = SwiftLexer()

    /// Run all our navigation bar code super early to avoid bad animations on iPhone
    func configureNavigation() {
        title = NSLocalizedString("Free Coding", comment: "") + (coordinator?.titleSuffix(for: self) ?? "")
        navigationItem.largeTitleDisplayMode = .never
        extendedLayoutIncludesOpaqueBars = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Skip", comment: ""), style: .plain, target: self, action: #selector(skip))
        showHintButton()
    }

    /// Configures the UI with the correct content for our current activity.
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")
        assert(practiceData != nil, "You must assign some practice data before presenting this view controller.")

        // The prompt can only be simple HTML (e.g. <code></code>), but the source code is fully syntax highlighted.
        prompt.attributedText = practiceData.question.fromSimpleHTML()
        textView.theme = User.current.sourceCodeTheme
        textView.delegate = self

        // Attach a toolbar with common key symbols to make typing easier.
        textView.contentTextView.inputAccessoryView = UIView.editingToolbar(target: self, action: #selector(insertCharacter))

        // Make sure our text view stays out of the way of the keyboard rather than scrolling under it.
        textView.contentTextView.avoidKeyboard()

        // If we have starting code, use it.
        if practiceData.startingCode.isEmpty == false {
            // add the starting code, with a line break afterwards so the user can start typing below
            textView.text = "\(practiceData.startingCode)\n"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showFirstTimeAlert(name: "FreeCoding", title: NSLocalizedString("Tip", comment: ""), message: NSLocalizedString("Unwrap is able to understand a variety of different solutions to each problem, but it's not perfect. If you enter a valid solution that is not accepted, please let us know so we can add it and make Unwrap better for everyone!", comment: ""))
    }

    /// Shows the hint button. This gets called in more than one place, because we replace it with a Done button when the text view is being edited.
    @objc func showHintButton() {
        textView?.contentTextView.resignFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Hint", comment: ""), style: .plain, target: self, action: #selector(hint))
    }

    @objc func hint() {
        showAlert(body: practiceData.hint)
    }

    @objc func skip() {
        coordinator?.skipPracticing()
    }

    /// Check whether the user's answer was correct and either update the UI to reflect their answer or move on.
    @IBAction func checkAnswer(_ sender: Any) {
        let result = practiceData.check(answer: textView.text)

        if result.isCorrect == false && coordinator?.retriesAllowed == true {
            skipOrRetry()
        } else {
            if isShowingAnswer {
                coordinator?.answerSubmitted(from: self, wasCorrect: result.isCorrect)
            } else {
                isShowingAnswer = true

                if result.isCorrect {
                    answerButton.correctAnswer()
                } else {
                    answerButton.wrongAnswer()
                }
            }
        }
    }

    /// Give users the choice of trying again or skipping
    func skipOrRetry() {
        showAlert(title: NSLocalizedString("That's not quite right!", comment: ""), body: NSLocalizedString("Check your code carefully, and try going for the simplest solution that works.", comment: ""), coordinator: nil, alternateTitle: nil, alternateAction: nil)
    }

    /// Allows users to dismiss the keyboard when they are ready, so they can tap submit
    func textViewDidBeginEditing(_ textView: SyntaxTextView) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(showHintButton))
    }

    /// Called when the user taps a key symbol in our input accessory view.
    @objc func insertCharacter(_ sender: UIBarButtonItem) {
        guard let value = UnicodeScalar(sender.tag) else { return }
        let string = String(value)
        textView.insertText(string)
        UIDevice.current.playInputClick()
    }

    // If we dynamically changed between light and dark mode while the app was running, make sure we refresh our layout to reflect the theme.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            textView.theme = User.current.sourceCodeTheme
        }
    }
}

extension FreeCodingViewController: SyntaxTextViewDelegate {
    /// Send back our Swift lexer for this source code.
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
}
