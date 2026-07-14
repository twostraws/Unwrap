//
//  Answer.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

struct Answer {
    var text: String
    var subtitle: String
    var isCorrect: Bool
    var isSelected: Bool

    /// Returns whether choosing True or False for this answer was correct.
    func isCorrectAnswer(for selectedTrue: Bool) -> Bool {
        selectedTrue == isCorrect
    }
}
