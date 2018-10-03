//
//  SingleSelectReviewViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import SavannaKit
import SourceEditor
import UIKit

class SingleSelectReviewViewController: ReviewViewController, Storyboarded, Sequenced {
    struct Answer {
        var text: String
        var isCorrect: Bool
    }

    @IBOutlet var prompt: UILabel!
    @IBOutlet var code: SyntaxTextView!

    @IBOutlet var answerButtons: UIStackView!
    @IBOutlet var trueButton: UIButton!
    @IBOutlet var falseButton: UIButton!

    /// The current question in the answer sequence.
    var questionNumber = 1

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
            answers += review.correct.map { Answer(text: $0, isCorrect: true) }
            answers += review.wrong.map { Answer(text: $0, isCorrect: false) }
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
    }
}

extension SingleSelectReviewViewController: SyntaxTextViewDelegate {
    /// Send back our Swift lexer for this source code.
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
}
