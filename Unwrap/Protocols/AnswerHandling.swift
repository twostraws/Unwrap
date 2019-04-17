//
//  AnswerHandling.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Conforming types must be able to handle answers coming in for a sequence of view controllers.
protocol AnswerHandling {
    mutating func answerSubmitted(from: UIViewController, wasCorrect: Bool)
    func titleSuffix(for: Sequenced) -> String
}
