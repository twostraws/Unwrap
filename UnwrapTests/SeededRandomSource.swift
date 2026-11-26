//
//  SeededRandomSource.swift
//  UnwrapTests
//

import Foundation
@testable import Unwrap

final class SeededRandomSource: RandomProviding {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    func nextInt(in range: ClosedRange<Int>) -> Int {
        precondition(range.isEmpty == false)

        let signBit = UInt64(1) << 63
        let lowerBound = UInt64(bitPattern: Int64(range.lowerBound)) ^ signBit
        let upperBound = UInt64(bitPattern: Int64(range.upperBound)) ^ signBit
        let width = upperBound &- lowerBound &+ 1
        let offset: UInt64

        if width == 0 {
            offset = next()
        } else {
            let threshold = (0 &- width) % width
            var value = next()

            while value < threshold {
                value = next()
            }

            offset = value % width
        }

        let orderedResult = lowerBound &+ offset
        return Int(Int64(bitPattern: orderedResult ^ signBit))
    }

    private func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return value ^ (value >> 31)
    }
}
