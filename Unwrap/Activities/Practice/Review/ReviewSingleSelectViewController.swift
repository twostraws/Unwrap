//
//  ReviewSingleSelectViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class ReviewSingleSelectViewController: SingleSelectReviewViewController {

    @objc override func skip() {
        coordinator?.skipPracticing()
    }
}
