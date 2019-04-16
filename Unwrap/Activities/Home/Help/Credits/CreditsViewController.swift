//
//  CreditsViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class CreditsViewController: UIViewController, Storyboarded {
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Credits"

        let contents = String(bundleName: "Credits.md")
        textView.attributedText = contents.fromSimpleMarkdown()
    }

    override func viewDidLayoutSubviews() {
        // Set content offset to zero to make sure the textview starts from the top
        // when the view is laid out.
        textView.setContentOffset(.zero, animated: false)
    }
}
