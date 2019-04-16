//
//  FreeCodingQuestion.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

/// One Free Coding practice question, loaded from JSON.
struct FreeCodingQuestion: Decodable {
    /// The user-facing question the user needs to answer.
    let question: String

    /// The user-facing hint giving the user a nudge.
    let hint: String

    /// The user-facing code that should be pre-filled in the UI to give the user the right start.
    let startingCode: String

    /// An array of possible answers that correctly answer the question.
    let answers: [String]
}
