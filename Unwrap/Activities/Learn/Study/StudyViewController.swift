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
    var coordinator: LearnCoordinator? {
        didSet {
            configureNavigation()
        }
    }

    var studyTextView = StudyTextView()
    var chapter = ""

    func configureNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: coordinator, action: #selector(LearnCoordinator.finishedStudying))

        // always include the safe area insets in the scroll view content adjustment
        studyTextView.contentInsetAdjustmentBehavior = .always
    }

    override func loadView() {
        studyTextView.linkDelegate = self
        view = studyTextView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")
    }

    // It's important we do content loading here, because a) loadView() is too early – here the text view has fully loaded and has its correct size, which means the movie image will be rendered correctly, and b) viewDidLayoutSubviews() is too late – it causes a layout loop.
    override func viewWillAppear(_ animated: Bool) {
        studyTextView.loadContent(chapter)
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
        } else {
            // this is some other kind of URL; open it up in a web view
            coordinator?.show(url: url)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // If our view controller is changing size we need to reload our content to make sure the movie view at the top correctly fills the full width of the screen.
        coordinator.animate(alongsideTransition: nil) { ctx in
            self.studyTextView.loadContent(self.chapter)
        }
    }
}
