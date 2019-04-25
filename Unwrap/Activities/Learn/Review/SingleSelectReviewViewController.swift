//
//  SingleSelectReviewViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Sourceful
import UIKit

class SingleSelectReviewViewController: ReviewViewController, Storyboarded {
    @IBOutlet var prompt: UILabel!
    @IBOutlet var code: SyntaxTextView!

    @IBOutlet var answerButtons: UIStackView!
    @IBOutlet var trueButton: UIButton!
    @IBOutlet var falseButton: UIButton!

    /// The array of all answers in the whole sequence. Tracking this allows us to ensure questions don't repeat.
    var answers = [Answer]()

    /// The current question they are answering.
    var currentAnswer: Answer!

    /// Set to true when the user has selected their answer and we are now telling them whether they are correct or not.
    var isShowingAnswer = false

    /// A lexer to highlight our source code.
    let lexer = SwiftLexer()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Review" + (coordinator?.titleSuffix(for: self) ?? "")
        prompt.attributedText = review.question.fromSimpleHTML()

        code.theme = User.current.sourceCodeTheme
        code.delegate = self

        if answers.isEmpty {
            // this is the first review screen; set up the answers here
            answers += review.correct.map { Answer(text: $0.answer, subtitle: $0.reason, isCorrect: true, isSelected: false) }
            answers += review.wrong.map { Answer(text: $0.answer, subtitle: $0.reason, isCorrect: false, isSelected: false) }
            answers.shuffle()
        }

        currentAnswer = answers.popLast()
        code.text = currentAnswer.text
        code.contentTextView.isEditable = false
    }

    @IBAction func selectAnswer(_ sender: UIButton) {
        if isShowingAnswer {
            coordinator?.answerSubmitted(from: self, wasCorrect: currentAnswer.isCorrect)
        } else {
            showAnswer(selected: sender)
        }
    }

    func showAnswer(selected: UIButton) {
        isShowingAnswer = true
        navigationItem.leftBarButtonItem?.isEnabled = false
        selected.setTitle("CONTINUE", for: .normal)

        // disable the other button
        if selected == trueButton {
            falseButton.disable()
        } else {
            trueButton.disable()
        }

        // update the button they tapped to reflect whether they were right or wrong
        if selected == trueButton {
            if currentAnswer.isCorrect {
                selected.correctAnswer()
            } else {
                selected.wrongAnswer()
            }
        } else {
            if currentAnswer.isCorrect {
                selected.wrongAnswer()
            } else {
                selected.correctAnswer()
            }
        }

        addReasonToTitle()
    }

    /// If their answer is wrong and we have some explanatory text explaining why it's wrong, show it.
    func addReasonToTitle() {
        if !currentAnswer.subtitle.isEmpty {
            let newTopString = NSMutableAttributedString(attributedString: "\(review.question)\n\n".fromSimpleHTML())
            let newBottomString = currentAnswer.subtitle.fromSimpleHTML().formattedAsExplanation()

            newTopString.append(newBottomString)
            prompt.attributedText = newTopString
        }
    }
}

extension SingleSelectReviewViewController: SyntaxTextViewDelegate {
    /// Send back our Swift lexer for this source code.
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
}
