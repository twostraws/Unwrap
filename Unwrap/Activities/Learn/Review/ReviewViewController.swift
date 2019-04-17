//
//  ReviewViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class ReviewViewController: UIViewController, AlertShowing, PracticingViewController {
    var coordinator: (AnswerHandling & Skippable)?

    var questionNumber = 1

    var practiceType = "review"

    var sectionName = ""
    var review: StudyReview!

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        navigationItem.largeTitleDisplayMode = .never

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skip))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hint", style: .plain, target: self, action: #selector(hint))
    }

    @objc func hint() {
        showAlert(body: review.hint)
    }

    @objc func skip() {
        coordinator?.skipReviewing()
    }
}
