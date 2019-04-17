//
//  UITableViewCell-Styling.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension UITableViewCell {
    /// Styles a table view cell as representing a correct answer.
    func correctAnswer() {
        backgroundColor = UIColor(bundleName: "ReviewCorrect")
        multipleSelectionBackgroundView?.backgroundColor = backgroundColor
        textLabel?.textColor = .white
        detailTextLabel?.textColor = .white
        tintColor = .white
    }

    /// Styles a table view cell as representing a wrong answer.
    func wrongAnswer() {
        backgroundColor = UIColor(bundleName: "ReviewWrong")
        multipleSelectionBackgroundView?.backgroundColor = backgroundColor
        textLabel?.textColor = .white
        detailTextLabel?.textColor = .white
        tintColor = .white
    }
}
