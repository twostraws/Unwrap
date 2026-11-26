//
//  ChallengeResult.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

/// Stores one historical score from the daily challenge.
struct ChallengeResult: Codable, Hashable, Identifiable {
    let date: Date
    let score: Int

    var id: Date { date }

    var shareText: String {
        "I scored \(score) in Unwrap's daily challenge for \(date.formatted). Download it here: \(Unwrap.appURL) (via @twostraws)"
    }
}
