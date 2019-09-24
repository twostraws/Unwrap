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

        // FIXME: iOS 12 used a clear color for the checkmark inside a selected table view cell, and the tint color affected the circle around the check. iOS 13 uses a white color for the checkmark, which means if we use pure white tint color the checkmark becomes invisible. Compromise: use a blended white, so the check still stands out, but the old behavior was nicer. Perhaps this will be fixed in the future.
        tintColor = UIColor.white.withAlphaComponent(0.35)
    }

    /// Styles a table view cell as representing a wrong answer.
    func wrongAnswer() {
        backgroundColor = UIColor(bundleName: "ReviewWrong")
        multipleSelectionBackgroundView?.backgroundColor = backgroundColor
        textLabel?.textColor = .white
        detailTextLabel?.textColor = .white

        // FIXME: iOS 12 used a clear color for the checkmark inside a selected table view cell, and the tint color affected the circle around the check. iOS 13 uses a white color for the checkmark, which means if we use pure white tint color the checkmark becomes invisible. Compromise: use a blended white, so the check still stands out, but the old behavior was nicer. Perhaps this will be fixed in the future.
        tintColor = UIColor.white.withAlphaComponent(0.35)
    }

    /// Styles a table view cell as representing an unknown answer.
    func unknownAnswer() {
        if #available(iOS 13, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }

        multipleSelectionBackgroundView?.backgroundColor = backgroundColor
        tintColor = nil
    }
}
