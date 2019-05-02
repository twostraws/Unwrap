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

        switch selectionMode {
        case .challenge:
            prompt.text = "Please select a challenge to begin"

        case .news:
            prompt.text = "Please select an article to read"

        case .practice:
            prompt.text = "Please select a practice activity to begin"
        }
    }
}
