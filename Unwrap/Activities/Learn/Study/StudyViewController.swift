//
//  StudyViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Responsible for showing one chapter of the book as text.
class StudyViewController: UIViewController, TappableTextViewDelegate {
    var coordinator: LearnCoordinator?
    var studyTextView = StudyTextView()
    var chapter = ""

    override func loadView() {
        studyTextView.linkDelegate = self
        studyTextView.loadContent(chapter)
        view = studyTextView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: coordinator, action: #selector(LearnCoordinator.finishedStudying))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // warn users there might be more content to scroll through
        studyTextView.flashScrollIndicators()
    }

    /// Most chapters have a video, so this catches link taps and triggers video playback.
    func linkTapped(_ url: URL) {
        let action = url.lastPathComponent

        if action == "playVideo" {
            coordinator?.playStudyVideo()
        }
    }
}
