//
//  Condition.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

/// A single condition, loaded from JSON.
struct Condition: Decodable {
    /// The left side of the condition, e.g. "VALUE_1|count"
    var left: String

    /// The check for this condition, e.g. >
    var check: String

    /// The right side of the condition, e.g. 5
    var right: String

    // swiftlint:disable:next cyclomatic_complexity
    func evaluatesTrue(values: [String], operators: [String]) -> Bool {
        // The left, check, and right can all contain placeholders and filters, e.g. "VALUE_1|count", "OPERATOR_0", and "VALUE_0". So, resolve them up front.
        let resolvedLeft = left.resolvingPlaceholder(values: values).resolvingFilters()
        let resolvedCheck = resolveCheck(check, with: operators)
        let resolvedRight = right.resolvingPlaceholder(values: values).resolvingFilters()

        // Now decide what the actual condition is, and check whether it's true.
        switch resolvedCheck {
        case ">":
            if let intLeft = Int(resolvedLeft), let intRight = Int(resolvedRight) {
                // evaluate this condition as an integer
                return intLeft > intRight
            } else {
                // evalute as a string
                return resolvedLeft > resolvedRight
            }

        case ">=":
            if let intLeft = Int(resolvedLeft), let intRight = Int(resolvedRight) {
                // evaluate this condition as an integer
                return intLeft >= intRight
            } else {
                // evalute as a string
                return resolvedLeft >= resolvedRight
            }

        case "<":
            if let intLeft = Int(resolvedLeft), let intRight = Int(resolvedRight) {
                // evaluate this condition as an integer
                return intLeft < intRight
            } else {
                // evalute as a string
                return resolvedLeft < resolvedRight
            }

        case "<=":
            if let intLeft = Int(resolvedLeft), let intRight = Int(resolvedRight) {
                // evaluate this condition as an integer
                return intLeft <= intRight
            } else {
                // evalute as a string
                return resolvedLeft <= resolvedRight
            }

        case "==":
            return resolvedLeft == resolvedRight

        case "!=":
            return resolvedLeft != resolvedRight

        default:
            fatalError("Unknown check: \(check)")
        }
    }

    private func resolveCheck(_ string: String, with operators: [String]) -> String {
        guard string.hasPrefix("OPERATOR_") else {
            return string
        }

        let operatorNumber = string.dropFirst(9) // OPERATOR_

        guard let operatorInteger = Int(operatorNumber) else {
            fatalError("Unknown operator number \(string)")
        }

        return operators[operatorInteger]
    }
}
