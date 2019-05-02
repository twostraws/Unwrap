//
//  PracticingViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Each of our practice view controllers must have a coordinator, a question number (so we know its position in the sequence), and a practice type so that we can track how many times it has been used.
protocol PracticingViewController: UIViewController, Sequenced {
    var coordinator: (Skippable & AnswerHandling)? { get set }
    var questionNumber: Int { get set }
    var practiceType: String { get }
}
