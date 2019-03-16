//
//  WrongAnswer.swift
//  Unwrap
//
//  Created by Paul Hudson on 04/03/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import Foundation

// A type that stores some answer text along with an explanation of why it's incorrect.
struct ReasonedAnswer: Decodable {
    var answer: String
    var reason: String
}
