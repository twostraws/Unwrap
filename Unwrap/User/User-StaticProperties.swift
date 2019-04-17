//
//  User-StaticProperties.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension User {
    static var current: User!

    /// How many points we award for fixed tasks.
    static let pointsForLearning = 100
    static let pointsForReviewing = 100
    static let pointsForPracticing = 20 // per question answered correctly

    /// Stores the highest score for a given rank bracket.
    /// So, rank 1 ends at 200.
    static let rankLevels = [
        0, // 0
        200, // 1
        500, // 2
        1000, // 3
        2000, // 4
        3000, // 5
        4000, // 6
        5000, // 7
        6500, // 8
        8000, // 9
        10000, // 10
        12500, // 11
        15000, // 12
        20000, // 13
        25000, // 14
        30000, // 15
        40000, // 16
        50000, // 17
        65000, // 18
        80000, // 19
        100000, // 20
        Int.max // 21
    ]

    /// A Very Small Number That Is Not 0, allowing us to draw a little of the activity ring even when the user has 0 for rank fraction.
    static let smallestRankFraction: Double = 0.001
}
