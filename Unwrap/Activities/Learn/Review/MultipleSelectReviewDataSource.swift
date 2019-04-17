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

        // have 3-5 correct answers, and the remaining (out of 8) being wrong
        let correctAnswers = Int.random(in: 3...5)
        let wrongAnswers = 8 - correctAnswers

        for index in 0..<correctAnswers {
            answers.append(Answer(text: review.correct[index].answer, subtitle: review.correct[index].reason, isCorrect: true, isSelected: false))
        }

        for index in 0..<wrongAnswers {
            answers.append(Answer(text: review.wrong[index].answer, subtitle: review.wrong[index].reason, isCorrect: false, isSelected: false))
        }

        answers.shuffle()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let answer = answers[indexPath.row]

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
            cell.detailTextLabel?.attributedText = answer.subtitle.fromSimpleHTML().formattedAsExplanation()
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
                cell.detailTextLabel?.textColor = .black

                if answer.isCorrect {
                    cell.wrongAnswer()
                } else {
                    cell.correctAnswer()
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
