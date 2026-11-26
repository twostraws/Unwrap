//
//  SystemRandomSource.swift
//  Unwrap
//

import Foundation

final class SystemRandomSource: RandomProviding {
    func nextInt(in range: ClosedRange<Int>) -> Int {
        Int.random(in: range)
    }
}
