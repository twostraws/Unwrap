//
//  ReviewMultipleSelectViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class ReviewMultipleSelectViewController: MultipleSelectReviewViewController {
    @objc override func skip() {
        coordinator?.skipPracticing()
    }

    override func getTitle() -> String {
        return "Review" + (coordinator?.titleSuffix(for: self) ?? "")
    }
}
