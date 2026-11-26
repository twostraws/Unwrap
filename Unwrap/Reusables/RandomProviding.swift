//
//  RandomProviding.swift
//  Unwrap
//

import Foundation

protocol RandomProviding: AnyObject {
    func nextInt(in range: ClosedRange<Int>) -> Int
}

extension RandomProviding {
    func element<Element>(from values: [Element]) -> Element? {
        guard values.isEmpty == false else { return nil }
        return values[nextInt(in: 0...(values.count - 1))]
    }

    func shuffled<Element>(_ values: [Element]) -> [Element] {
        guard values.count > 1 else { return values }

        var result = values

        for index in stride(from: result.count - 1, through: 1, by: -1) {
            let otherIndex = nextInt(in: 0...index)
            if index != otherIndex {
                result.swapAt(index, otherIndex)
            }
        }

        return result
    }
}
