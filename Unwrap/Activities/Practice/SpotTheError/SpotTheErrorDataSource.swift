//
//  SpotTheErrorDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Spot the Error table view.
class SpotTheErrorDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    // Where to report changes when the user taps a row
    weak var delegate: SpotTheErrorViewController?

    /// The current question they are solving, along with hints and solutions.
    var practiceData: SpotTheErrorPractice

    /// Stores whether we are currently showing the question or the showing the answers.
    var isShowingAnswers = false

    /// The currently selected error line, if any.
    var selectedAnswer: Int? {
        didSet {
            delegate?.selectionChanged()
        }
    }

    /// Returns true when the user selected the correct line.
    var isUserCorrect: Bool {
        return selectedAnswer == practiceData.lineNumber
    }

    /// The default initializer
    init(practiceData: SpotTheErrorPractice) {
        self.practiceData = practiceData
    }

    /// Maps table row count directly to however many lines of code we have
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return practiceData.code.count
    }

    /// Styles each table view cell as being a regular row, a correct row, or a wrong row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.attributedText = practiceData.code[indexPath.row].syntaxHighlighted()
        cell.textLabel?.font = Unwrap.codeFont

        if let selectedAnswer = selectedAnswer, isShowingAnswers == true {
            cell.textLabel?.textColor = .white

            if indexPath.row == selectedAnswer {
                if indexPath.row == practiceData.lineNumber {
                    cell.backgroundColor = UIColor(bundleName: "ReviewCorrect")
                } else {
                    cell.backgroundColor = UIColor(bundleName: "ReviewWrong")
                }
            } else {
                if indexPath.row == practiceData.lineNumber {
                    cell.backgroundColor = UIColor(bundleName: "ReviewWrong")
                } else {
                    cell.backgroundColor = .white
                    cell.textLabel?.textColor = .black
                }
            }
        }

        return cell
    }

    /// Stops the user from even thinking about changing their selections once they've shown the answers.
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if isShowingAnswers {
            return false
        } else {
            return true
        }
    }

    /// Stops the user from changing their selections once they've shown the answers.
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isShowingAnswers {
            return nil
        } else {
            if tableView.indexPathForSelectedRow == indexPath {
                tableView.deselectRow(at: indexPath, animated: false)
                selectedAnswer = nil
                return nil
            } else {
                selectedAnswer = indexPath.row
                return indexPath
            }
        }
    }
}
