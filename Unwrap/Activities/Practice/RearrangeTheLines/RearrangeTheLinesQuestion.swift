//
//  RearrangeLinesQuestion.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

/// One Rearrange the Lines practice question, loaded from JSON.
struct RearrangeTheLinesQuestion: Decodable {
    let question: String
    let hint: String
    let code: String
}
