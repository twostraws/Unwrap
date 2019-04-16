//
//  StudyReview.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// One item of review following a book chapter
struct StudyReview: Decodable {
    /// The user-facing title of this chapter.
    var title: String

    /// If set, some user-facing text to be shown to users between the chapter text and review.
    var postscript: String

    /// Whether it's single selection (one answer on each screen.) or multiple selection (several answers on each screen.)
    var reviewType: String

    /// The user-facing question text.
    var question: String

    /// The user-facing hint text.
    var hint: String

    /// An array of correct answers.
    var correct: [ReasonedAnswer]

    /// An array of wrong answers.
    var wrong: [ReasonedAnswer]

    /// When set to true syntax highlight this text at runtime; when set to false, just bold <code> blocks;.
    var syntaxHighlighting: Bool

    /// Loads one review filew for a specific chapter
    static func review(for name: String) -> StudyReview {
        var review = Bundle.main.decode(StudyReview.self, from: "\(name).json")
        review.correct = review.correct.shuffled()
        review.wrong = review.wrong.shuffled()
        return review
    }
}
