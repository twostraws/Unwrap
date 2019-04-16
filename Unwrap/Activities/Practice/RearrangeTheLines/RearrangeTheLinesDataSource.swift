//
//  RearrangeTheLinesDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Rearrange the Lines table view.
class RearrangeTheLinesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var practiceData: RearrangeTheLinesPractice

    // The current array of code lines in whatever order the user has placed them.
    var currentCode: [String]

    // Stores whether we are currently showing the question or the showing the answers.
    var isShowingAnswers = false

    // Loops over all our code to find whether it's correct or not. We can't just do a simple array comparison because we need to remove whitespace – we don't care if the user matched one brace with another when the indents are different, for example.
    var isUserCorrect: Bool {
        for lineNumber in 0 ..< practiceData.code.count {
            let correctCode = practiceData.code[lineNumber].trimmingCharacters(in: .whitespacesAndNewlines)
            let actualCode = currentCode[lineNumber].trimmingCharacters(in: .whitespacesAndNewlines)

            if correctCode != actualCode {
                return false
            }
        }

        return true
    }

    init(practiceData: RearrangeTheLinesPractice) {
        self.practiceData = practiceData
        currentCode = practiceData.code.shuffled()

        // In case we accidentally shuffled into the original order, keep on shuffling until the lines are different.
        repeat {
            currentCode = practiceData.code.shuffled()
        } while currentCode == practiceData.code
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCode.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = currentCode[indexPath.row]

        if isShowingAnswers {
            // We're showing the answers, so trim this line's whitespace and trim the correct line's whitespace, then compare the two to see if they are correct.
            let correctCode = practiceData.code[indexPath.row].trimmingCharacters(in: .whitespacesAndNewlines)
            let actualCode = currentCode[indexPath.row].trimmingCharacters(in: .whitespacesAndNewlines)

            if correctCode == actualCode {
                cell.backgroundColor = UIColor(bundleName: "ReviewCorrect")
            } else {
                cell.backgroundColor = UIColor(bundleName: "ReviewWrong")
            }

            cell.textLabel?.textColor = .white
        }

        return cell
    }

    /// Even though this table is editable (so they can move rows), we don't want add/delete icons to appear.
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    /// Even though this table is editable (so they can move rows), we don't want the rows indented.
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    /// Make sure all cells are movable, because that's kind of the point of this activity.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    /// Handle cell moves correctly.
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let line = currentCode[sourceIndexPath.row]
        currentCode.remove(at: sourceIndexPath.row)
        currentCode.insert(line, at: destinationIndexPath.row)
    }
}
