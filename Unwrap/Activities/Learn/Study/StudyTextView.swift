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
    func loadContent(_ contentName: String) {
        // load our chapter text
        attributedText = NSAttributedString(chapterName: contentName, width: bounds.width)

        if #available(iOS 13, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }

        isEditable = false
    }
}
