//
//  CodeError.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Stores complete data about one code error.
struct CodeError {
    var code: String
    var error: CodeErrorType
    var lineNumber: Int
}
