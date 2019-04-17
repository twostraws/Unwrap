//
//  UnwrapTests.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import XCTest
@testable import Unwrap

/// An enum representing the three major cases of practical experiments as far a O 'm awre.
enum TestErrors: Error {
    case badBadge
    case badChapter
    case badPath
}
