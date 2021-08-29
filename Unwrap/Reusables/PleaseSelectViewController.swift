//
//  PleaseSelectViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 02/05/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class PleaseSelectViewController: UIViewController, Storyboarded {
    @IBOutlet var logo: ShapeView!
    @IBOutlet var prompt: UILabel!
    var selectionMode = Unwrap.ActivityType.practice

    override func viewDidLoad() {
        super.viewDidLoad()

        extendedLayoutIncludesOpaqueBars = true
        logo.path = UIBezierPath.logo

        let tap = UITapGestureRecognizer(target: self, action: #selector(logoTapped))
        logo.addGestureRecognizer(tap)

        switch selectionMode {
        case .learn:
            prompt.text = NSLocalizedString("Please select a topic to learn", comment: "")

        case .challenges:
            if User.current.hasCompletedTodaysChallenge {
                prompt.text = NSLocalizedString("Come back tomorrow", comment: "")
            } else {
                prompt.text = NSLocalizedString("Start today's challenge when you're ready", comment: "")
            }

        case .news:
            prompt.text = NSLocalizedString("Please select an article to read", comment: "")

        case .practice:
            prompt.text = NSLocalizedString("Please select a practice activity to begin", comment: "")

        default:
            prompt.text = ""
        }
    }

    @objc func logoTapped() {
        logo.draw(delay: 0, duration: 2, keyFrameValues: [0, 0.129, 0.373, 0.58, 0.928, 1.0])
    }
}
