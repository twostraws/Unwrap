//
//  UIButton-Types.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension UIButton {
    /// A fixed height for our buttons, so they should mostly be nice and big.
    static let primaryButtonHeight: CGFloat = 88

    /// Creates a main app button in our primary color.
    static func primary(frame: CGRect) -> UIButton {
        let button = UIButton(type: .custom)

        button.showsTouchWhenHighlighted = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(bundleName: "Primary")
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        button.frame = frame

        return button
    }

    /// Creates a main app button in our secondary color.
    static func secondary(frame: CGRect) -> UIButton {
        let button = UIButton.primary(frame: frame)
        button.backgroundColor = UIColor(bundleName: "Secondary")
        return button
    }

    /// Adjusts a button so that it represents a correct answer.
    func correctAnswer() {
        setImage(UIImage(bundleName: "Check"), for: .normal)
        backgroundColor = UIColor(bundleName: "ReviewCorrect")
    }

    /// Adjusts a button so that it represents a wrong answer.
    func wrongAnswer() {
        setImage(UIImage(bundleName: "Cross"), for: .normal)
        backgroundColor = UIColor(bundleName: "ReviewWrong")
    }
}
