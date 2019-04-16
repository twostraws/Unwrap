//
//  ChallengeResult.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Stores one historical score from the daily challenge.
struct ChallengeResult: Codable {
    var date: Date
    var score: Int
}
