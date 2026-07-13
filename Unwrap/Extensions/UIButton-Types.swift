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
        var configuration = UIButton.Configuration.filled()

        configuration.baseBackgroundColor = UIColor(bundleName: "Primary")
        configuration.baseForegroundColor = .white
        configuration.imagePadding = 20
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 0
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.boldSystemFont(ofSize: 22)
            return outgoing
        }
        button.configuration = configuration
        button.tintColor = .white
        button.frame = frame

        return button
    }

    /// Creates a main app button in our secondary color.
    static func secondary(frame: CGRect) -> UIButton {
        let button = UIButton.primary(frame: frame)
        button.setBackgroundColor(UIColor(bundleName: "Secondary"))
        return button
    }

    /// Adjusts a button so that it represents a correct answer.
    func correctAnswer() {
        setAppearance(image: UIImage(bundleName: "Check"), backgroundColor: UIColor(bundleName: "ReviewCorrect"))
    }

    /// Adjusts a button so that it represents a wrong answer.
    func wrongAnswer() {
        setAppearance(image: UIImage(bundleName: "Cross"), backgroundColor: UIColor(bundleName: "ReviewWrong"))
    }

    func disable() {
        setBackgroundColor(UIColor(bundleName: "Disabled"))
        isUserInteractionEnabled = false
    }

    private func setAppearance(image: UIImage, backgroundColor: UIColor) {
        if var configuration {
            configuration.image = image
            configuration.baseBackgroundColor = backgroundColor
            self.configuration = configuration
        } else {
            setImage(image, for: .normal)
            self.backgroundColor = backgroundColor
        }
    }

    private func setBackgroundColor(_ color: UIColor) {
        if var configuration {
            configuration.baseBackgroundColor = color
            self.configuration = configuration
        } else {
            backgroundColor = color
        }
    }
}
