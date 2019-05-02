//
//  PleaseSelectViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 02/05/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class PleaseSelectViewController: UIViewController, Storyboarded {
    enum SelectionMode {
        case challenge
        case news
        case practice
    }

    @IBOutlet var logo: ShapeView!
    @IBOutlet var prompt: UILabel!
    var selectionMode = SelectionMode.practice

    override func viewDidLoad() {
        super.viewDidLoad()

        extendedLayoutIncludesOpaqueBars = true
        logo.path = UIBezierPath.logo

        let tap = UITapGestureRecognizer(target: self, action: #selector(logoTapped))
        logo.addGestureRecognizer(tap)

        switch selectionMode {
        case .challenge:
            // it seems weird to repeat the text here
            prompt.text = ""

        case .news:
            prompt.text = "Please select an article to read"

        case .practice:
            prompt.text = "Please select a practice activity to begin"
        }
    }

    @objc func logoTapped() {
        logo.draw(delay: 0, duration: 2, keyFrameValues: [0, 0.129, 0.373, 0.58, 0.928, 1.0])
    }
}
