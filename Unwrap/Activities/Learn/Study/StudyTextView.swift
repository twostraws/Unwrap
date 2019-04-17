//
//  StudyTextView.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A trivial text view subclass that loads Swift in Sixty Seconds chapters.
class StudyTextView: TappableTextView {
    override func layoutSubviews() {
        super.layoutSubviews()

        // act on taps as soon as they occur
        lookForAttributedTaps()
    }

    func loadContent(_ contentName: String) {
        // load our chapter text
        attributedText = NSAttributedString(chapterName: contentName)
        backgroundColor = .white
        isEditable = false
    }
}
