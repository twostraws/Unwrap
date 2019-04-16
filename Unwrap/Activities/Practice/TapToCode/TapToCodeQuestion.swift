//
//  TapToCodeQuestion.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// One Tap to Code practice question, loaded from JSON.
struct TapToCodeQuestion: Decodable {
    let question: String
    let existingCode: String
    let components: [String]
}
