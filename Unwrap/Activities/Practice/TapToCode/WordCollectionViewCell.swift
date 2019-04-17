//
//  WordCollectionViewCell.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A customized collection view cell that has a label, and some styling around to make it stand out as something that can be placed.
class WordCollectionViewCell: UICollectionViewCell {
    @IBOutlet var textLabel: UILabel!

    override func awakeFromNib() {
        clipsToBounds = false

        // Give each cell a gentle border…
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor

        // …and a very gentle shadow.
        layer.shadowOpacity = 0.2
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 1, height: 1)
    }

    // Style this as being in the correct position.
    func correctAnswer() {
        backgroundColor = UIColor(bundleName: "ReviewCorrect")
        textLabel?.textColor = .white
        tintColor = .white
    }

    // Style this as being in the wrong position.
    func wrongAnswer() {
        backgroundColor = UIColor(bundleName: "ReviewWrong")
        textLabel?.textColor = .white
        tintColor = .white
    }
}
