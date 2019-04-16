//
//  TypeCheckerDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Type Checker table view.
class TypeCheckerDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    /// The current question they are solving, along with hints and solutions.
    var review: TypeCheckerPractice

    /// Stores whether we are currently showing the question or the showing the answers.
    var isShowingAnswers = false

    /// Returns whether the user has used all the code correctly or not.
    var isUserCorrect: Bool {
        if isShowingAnswers {
            for answer in review.answers {
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

    init(review: TypeCheckerPractice) {
        self.review = review
    }

    /// Sends back one row for each of our answers.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return review.answers.count
    }

    /// Creates a table view cell with syntax highlighting. This must always ensure our cells have a multiple selection background view, because that's what gets recolored when showing answers.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let answer = review.answers[indexPath.row]
        cell.textLabel?.attributedText = answer.text.syntaxHighlighted()
        cell.textLabel?.font = Unwrap.codeFont

        // make sure we have a custom multiple selection background view so we can recolor when showing answers
        if cell.multipleSelectionBackgroundView == nil {
            cell.multipleSelectionBackgroundView = UIView()
        }

        return cell
    }

    /// Styles each cell as being unknown (regular styling), correct, or wrong.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let answer = review.answers[indexPath.row]
        cell.isSelected = answer.isSelected

        if isShowingAnswers {
            if answer.isSelected {
                if answer.isCorrect {
                    cell.correctAnswer()
                } else {
                    cell.wrongAnswer()
                }
            } else {
                if answer.isCorrect {
                    cell.wrongAnswer()
                } else {
                    cell.unknownAnswer()
                }
            }
        }
    }

    /// Marks a specific answer as being chosen by the user.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        review.answers[indexPath.row].isSelected = true
    }

    /// Marks a specific answer as no longer being chosen by the user.
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        review.answers[indexPath.row].isSelected = false
    }

    // Stop the user from changing their selections once they've shown the answers.
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isShowingAnswers {
            return nil
        } else {
            return indexPath
        }
    }

    // Stop the user from even thinking about changing their selections once they've shown the answers.
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if isShowingAnswers {
            return false
        } else {
            return true
        }
    }
}
