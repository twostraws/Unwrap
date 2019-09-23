//
//  MultipleSelectReviewDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class MultipleSelectReviewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var review: StudyReview
    var answers = [Answer]()
    var isShowingAnswers = false

    var isUserCorrect: Bool {
        if isShowingAnswers {
            for answer in answers {
                if answer.isSelected {
                    if !answer.isCorrect {
                        return false
                    }
                } else {
                    if answer.isCorrect {
                        return false
                    }
                }
            }
        } else {
            return false
        }

        return true
    }

    init(review: StudyReview) {
        self.review = review

        for answer in review.correct {
            answers.append(Answer(text: answer.answer, subtitle: answer.reason, isCorrect: true, isSelected: false))
        }

        for answer in review.wrong {
            answers.append(Answer(text: answer.answer, subtitle: answer.reason, isCorrect: false, isSelected: false))
        }

        answers.shuffle()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let answer = answers[indexPath.row]

        // We need to start off every label with primary label text, even though it will be using an attributed string for its exact styling. Without this next line of code, cell re-use will cause a problem in questions without syntax highlighting: correct/wrong answers will have their text color set to white, and cell re-use will cause that to be propagated to cells with a white background color. While we could update unknownAnswer() to set a black text color, doing so would strip syntax highlighting from questions that have it enabled, so the best solution is to start with a black and let syntax highlighting / white color override as necessary.
        if #available(iOS 13, *) {
            cell.textLabel?.textColor = .label
        } else {
            cell.textLabel?.textColor = .black
        }

        if review.syntaxHighlighting == true {
            cell.textLabel?.font = Unwrap.codeFont
            cell.textLabel?.attributedText = answer.text.syntaxHighlighted()
        } else {
            cell.textLabel?.attributedText = answer.text.fromSimpleHTML()
        }

        // make sure we have a custom multiple selection background view so we can recolor when showing answers
        if cell.multipleSelectionBackgroundView == nil {
            cell.multipleSelectionBackgroundView = UIView()
        }

        // set the detail text label contents here to make sure we participate fully in Auto Layout cell sizing
        if isShowingAnswers {
            cell.detailTextLabel?.attributedText = answer.subtitle.fixingLineWrapping().fromSimpleHTML().formattedAsExplanation()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let answer = answers[indexPath.row]
        cell.isSelected = answer.isSelected

        if isShowingAnswers {
            if cell.isSelected {
                cell.detailTextLabel?.textColor = .white

                if answer.isCorrect {
                    cell.correctAnswer()
                } else {
                    cell.wrongAnswer()
                }
            } else {
                if #available(iOS 13, *) {
                    cell.detailTextLabel?.textColor = .label
                } else {
                    cell.detailTextLabel?.textColor = .black
                }

                if answer.isCorrect {
                    cell.wrongAnswer()
                } else {
                    cell.unknownAnswer()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        answers[indexPath.row].isSelected = true
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        answers[indexPath.row].isSelected = false
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // stop the user from changing their selections once they've shown the answers
        if isShowingAnswers {
            return nil
        } else {
            return indexPath
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // stop the user from even thinking about changing their selections once they've shown the answers
        if isShowingAnswers {
            return false
        } else {
            return true
        }
    }
}
