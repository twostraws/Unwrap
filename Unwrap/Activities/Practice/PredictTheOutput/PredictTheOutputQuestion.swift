//
//  PredictTheOutputQuestion.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

/// One Predict the Output practice question, loaded from JSON.
struct PredictTheOutputQuestion: Decodable {
    let code: String
    let answers: [PredictTheOutputAnswer]
}
