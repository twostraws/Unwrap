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
        loadContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // warn users there might be more content to scroll through
        studyTextView.flashScrollIndicators()
    }

    // A centralized method for loading the content for this chapter, so it can be used in various places.
    func loadContent() {
        studyTextView.loadContent(chapter)
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

    // If we dynamically changed between light and dark mode while the app was running, make sure we refresh our layout to reflect the theme.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Refuse to update the trait when running in the background. This isn't ideal, but NSAttributedString throws an exception when we load our wrapper HTML in the background, so we have no choice if we want to avoid a crash.
        guard UIApplication.shared.applicationState != .background else { return }

        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            loadContent()
        }
    }
}
