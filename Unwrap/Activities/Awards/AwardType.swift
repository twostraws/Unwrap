//
//  AwardType.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The four ways users can receive points: learning a chapter, reviewing a chapter, completing a practice activity, and completing a challenge.
enum AwardType {
    case learn(chapter: String)
    case review(chapter: String)
    case practice(type: String)
    case challenge
}
