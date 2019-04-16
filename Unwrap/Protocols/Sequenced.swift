//
//  Sequenced.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Used by any view controller that forms a sequence, allowing us to say "this is question 3 in the sequence."
protocol Sequenced {
    var questionNumber: Int { get set }
}
