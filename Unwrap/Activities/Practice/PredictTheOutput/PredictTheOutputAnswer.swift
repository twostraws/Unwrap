//
//  PredictTheOutputAnswer.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A single Predict the Output answer loaded from JSON.
struct PredictTheOutputAnswer: Decodable {
    var conditions: [Condition]?
    var text: String
}
