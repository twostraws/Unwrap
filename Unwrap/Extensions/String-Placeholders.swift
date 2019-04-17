//
//  String-Placeholders.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import JavaScriptCore

/// Words you'll see a lot in here:
/// - "names": Variable names, such as favoriteColor.
/// - "namesNatural": Variable names formatted in natural language, such as "favorite color".
/// - "values": Some example appropriate values for each random variable name, so for favorite colors that might be "red", "blue", "green", etc.
/// - "operators": The list of randomly generated operators.

extension String {
    /// Resolves all placeholders in a string: fills out variable names, provides values, and so on.
    func resolvingPlaceholders(names: [String] = [], namesNatural: [String] = [], values: [String] = [], operators: [String] = []) -> (output: String, names: [String], namesNatural: [String], values: [String], operators: [String]) {
        var names = names
        var namesNatural = namesNatural
        var values = values
        var operators = operators

        // First replace all instances of CONSTANT_OR_VARIABLE with let or var.
        var output = self
        output = resolveLetVar(input: output)

        // Replace all instances of TRUE_OR_FALSE with true or false.
        output = resolveTrueFalse(input: output)

        // Replace all instances of RANDOM_INT_NAME with a random integer name.
        let randomIntResult = resolveRandomIntName(input: output)
        output = randomIntResult.output
        names.append(contentsOf: randomIntResult.names)
        namesNatural.append(contentsOf: randomIntResult.namesNatural)

        // Replace all instances of RANDOM_MEDIUM_INT with a number between 1 and 100.
        let randomMediumIntResult = resolveRandomInt(input: output, search: "MEDIUM", numberRange: 1...100)
        output = randomMediumIntResult.output
        values.append(contentsOf: randomMediumIntResult.values)

        // Replace all instances of RANDOM_SMALL_INT with a number between 1 and 10.
        let randomSmallIntResult = resolveRandomInt(input: output, search: "SMALL", numberRange: 1...10)
        output = randomSmallIntResult.output
        values.append(contentsOf: randomSmallIntResult.values)

        // Replace all instances of RANDOM_TINY_INT with a number between 1 and 3.
        let randomTinyIntResult = resolveRandomInt(input: output, search: "TINY", numberRange: 1...3)
        output = randomTinyIntResult.output
        values.append(contentsOf: randomTinyIntResult.values)

        // Replace all instances of RANDOM_STRING_NAME with a random string name.
        let randomStringResult = resolveRandomStringName(input: output)
        output = randomStringResult.output
        names.append(contentsOf: randomStringResult.names)
        namesNatural.append(contentsOf: randomStringResult.namesNatural)

        // Replace all instances of RANDOM_STRING_VALUE with a random string from the correct set of options.

        // WARNING WARNING WARNING
        // Sometimes we use RANDOM_STRING_NAME_0 to generate a string name, then later on – in a subsequent string – attempt to read the value. If this happens, we'll have at least one name in randomStringResult.name but no RANDOM_STRING_VALUE. This would normally cause us to generate the string name but no string values, which would cause problems in the subsequent string. Although this will sometimes not be a problem, we create some values just to be sure.
        if randomStringResult.names.count > 0 && !output.contains("RANDOM_STRING_VALUE") {
            // If we don't use the random string value, pretend it happens anyway to avoid problems.
            let dummyString = String(repeating: "RANDOM_STRING_VALUE_0", count: randomStringResult.names.count)
            let randomStringValueResult = resolveRandomStringValues(input: dummyString, possibleValues: randomStringResult.possibleValues)
            values.append(contentsOf: randomStringValueResult.values)
        } else {
            // We do use the string value correctly, so just resolve as normal.
            let randomStringValueResult = resolveRandomStringValues(input: output, possibleValues: randomStringResult.possibleValues)
            output = randomStringValueResult.output
            values.append(contentsOf: randomStringValueResult.values)
        }

        // Replace all instances of RANDOM_BOOL_NAME with a random string name.
        let randomBoolResult = resolveRandomBoolName(input: output)
        output = randomBoolResult.output
        names.append(contentsOf: randomBoolResult.names)

        // Replace all instances of RANDOM_OPERATOR with a random sign.
        let randomOperatorResult = resolveRandomOperators(input: output)
        output = randomOperatorResult.output
        operators.append(contentsOf: randomOperatorResult.operators)

        // Replace all instances of NAME_n with the name that was used.
        output = resolveNames(input: output, names: names)

        // Replace all instances of NAME_NATURAL_n with the natural name that was used.
        output = resolveNaturalNames(input: output, names: namesNatural)

        // Replace all instances of VALUE_n with the name that was used.
        output = resolveValues(input: output, values: values)

        // Resolve any calculations, e.g. ${6 * 2}.
        output = resolveCalculations(input: output)

        return (output, names, namesNatural, values, operators)
    }

    /// A simple helper that resolves all values down to a single string.
    func resolvingPlaceholder(values: [String]) -> String {
        return resolvingPlaceholders(values: values).output
    }

    /// Converts a string into a filtered string, or just returns the original string if no filter is present. A string with filter looks like "myValue|capitalized".
    func resolvingFilters() -> String {
        let split = components(separatedBy: "|")

        if split.count == 2 {
            // we have a filter!
            return split[0].applyingFilter(split[1])
        } else {
            return self
        }
    }

    /// Applies a filter to a string, such as counting its letters.
    func applyingFilter<T: StringProtocol>(_ filter: T) -> String {
        switch filter {
        case "count":
            // Send back the length of the string.
            return String(self.count)
        case "capitalized":
            // Capitalize individual words.
            return String(self.capitalized)
        case "capitalizedFirst":
            // Capitalize only the first word.
            return prefix(1).capitalized + dropFirst()
        default:
            fatalError("Unknown filter: \(filter)")
        }
    }

    ///  Converts CONSTANT_OR_VARIABLE into either "let" or "var"
    fileprivate func resolveLetVar(input: String) -> String {
        var output = input

        while let letvarRange = output.range(of: "CONSTANT_OR_VARIABLE") {
            let letOrVar = String.letOrVar()
            output = output.replacingOccurrences(of: "CONSTANT_OR_VARIABLE", with: letOrVar, options: [], range: letvarRange)
        }

        return output
    }

    ///  Converts TRUE_OR_FALSE into either "true" or "false"
    fileprivate func resolveTrueFalse(input: String) -> String {
        var output = input

        while let truefalseRange = output.range(of: "TRUE_OR_FALSE") {
            let trueOrFalse = Bool.random() ? "true" : "false"
            output = output.replacingOccurrences(of: "TRUE_OR_FALSE", with: trueOrFalse, options: [], range: truefalseRange)
        }

        return output
    }

    /// Creates an integer variable with a random name.
    fileprivate func resolveRandomIntName(input: String) -> (output: String, names: [String], namesNatural: [String]) {
        var output = input
        var names = [String]()
        var namesNatural = [String]()

        while let range = output.range(of: "RANDOM_INT_NAME") {
            // pick out a new random name, making sure we haven't already used it
            let result = Int.randomName()
            if names.contains(result.name) { continue }

            names.append(result.name)
            namesNatural.append(result.nameNatural)
            output = output.replacingOccurrences(of: "RANDOM_INT_NAME", with: result.name, options: [], range: range)
        }

        return (output, names, namesNatural)
    }

    /// Fills a placeholder with a random value between 1 and 9.
    fileprivate func resolveRandomInt(input: String, search: String, numberRange: ClosedRange<Int>) -> (output: String, values: [String]) {
        var output = input
        var values = [String]()
        let searchString = "RANDOM_\(search)_INT"

        while let range = output.range(of: searchString) {
            let randomNumber = String(Int.random(in: numberRange))
            values.append(randomNumber)
            output = output.replacingOccurrences(of: searchString, with: randomNumber, options: [], range: range)
        }

        return (output, values)
    }

    /// Creates a string variable with a random name.
    fileprivate func resolveRandomStringName(input: String) -> (output: String, names: [String], namesNatural: [String], possibleValues: [[String]]) {
        var output = input
        var names = [String]()
        var namesNatural = [String]()
        var possibleValues = [[String]]()

        while let range = output.range(of: "RANDOM_STRING_NAME") {
            // pick out a new random name, making sure we haven't already used it
            let result = String.randomName()
            if names.contains(result.name) { continue }

            names.append(result.name)
            namesNatural.append(result.nameNatural)
            possibleValues.append(result.values)

            output = output.replacingOccurrences(of: "RANDOM_STRING_NAME", with: result.name, options: [], range: range)
        }

        return (output, names, namesNatural, possibleValues)
    }

    /// Provides appropriate values for each string variable that was generated, e.g. "red", "green", etc, for a variable called "favoriteColor".
    fileprivate func resolveRandomStringValues(input: String, possibleValues: [[String]]) -> (output: String, values: [String]) {
        var output = input
        var values = [String]()
        var possibleValues = possibleValues

        // We want to make sure each value is used only once across all replacements, so this set will contain each value that is used.
        var usedValues = Set<String>()

        /// Match up to four different generated strings – "that ought to be enough for anyone!"
        for matchNumber in 0 ... 4 {
            // Look for the current value to replace.
            while let range = output.range(of: "RANDOM_STRING_VALUE_\(matchNumber)") {
                // These are the values we'll use for this replacement.
                var currentValues = possibleValues[matchNumber]

                // Find a unique value to use across all instances of this code.
                var valueToUse = currentValues[0]
                var valueToRead = 0

                while usedValues.contains(valueToUse) {
                    valueToRead += 1
                    valueToUse = currentValues[valueToRead]
                }

                // We have a unique value, so remember that we used it and perform the replacement.
                usedValues.insert(valueToUse)
                values.append(valueToUse)
                output = output.replacingOccurrences(of: "RANDOM_STRING_VALUE_\(matchNumber)", with: valueToUse, options: [], range: range)
            }
        }

        return (output, values)
    }

    /// Creates a bool variable with a random name.
    fileprivate func resolveRandomBoolName(input: String) -> (output: String, names: [String]) {
        var output = input
        var names = [String]()

        while let range = output.range(of: "RANDOM_BOOL_NAME") {
            // pick out a new random name, making sure we haven't already used it
            let result = Bool.randomName()
            if names.contains(result) { continue }

            names.append(result)
            output = output.replacingOccurrences(of: "RANDOM_BOOL_NAME", with: result, options: [], range: range)
        }

        return (output, names)
    }

    /// Creates a random operator.
    fileprivate func resolveRandomOperators(input: String) -> (output: String, operators: [String]) {
        var output = input
        var operators = [String]()

        while let range = output.range(of: "RANDOM_OPERATOR") {
            let randomOperator = String.randomOperator()
            operators.append(randomOperator)
            output = output.replacingOccurrences(of: "RANDOM_OPERATOR", with: randomOperator, options: [], range: range)
        }

        return (output, operators)
    }

    /// Replace any variable name placeholders (NAME_0, NAME_1, etc) with whatever actual variable name it refers to.
    fileprivate func resolveNames(input: String, names: [String]) -> String {
        var output = input
        let regex = NSRegularExpression("NAME_(\\d)")

        while let match = regex.firstMatch(in: output, options: [], range: NSRange(location: 0, length: output.utf16.count)) {
            let range = match.range(at: 1)

            if let swiftRange = Range(range, in: output) {
                let name = Int(output[swiftRange]) ?? 0
                output = output.replacingOccurrences(of: "NAME_\(name)", with: names[name], options: [])
            }
        }

        return output
    }

    /// Replace any name natural placeholders with the correct name natural form, e.g. "favorite color".
    fileprivate func resolveNaturalNames(input: String, names: [String]) -> String {
        var output = input

        // Make sure and check for filters, because we need name naturals to appear formatted with things like capitalizations.
        let regex = NSRegularExpression("NAME_NATURAL_(\\d)(\\|[^ ]+)?")

        while let match = regex.firstMatch(in: output, options: [], range: NSRange(location: 0, length: output.utf16.count)) {
            let wholeMatch = match.range(at: 0)
            let numberMatch = match.range(at: 1)
            let filterMatch = match.range(at: 2)

            let whole = output.substring(at: wholeMatch)
            let name = output.substring(at: numberMatch)

            // Find the variable that matches this name natural request.
            let nameToRead = Int(name) ?? 0
            let variableName = names[nameToRead]
            let resolvedVariableName: String

            // If we have a filter here, apply it before moving on.
            if filterMatch.length > 0 {
                let filter = output.substring(at: filterMatch).dropFirst()
                resolvedVariableName = variableName.applyingFilter(filter)
            } else {
                resolvedVariableName = variableName
            }

            output = output.replacingOccurrences(of: whole, with: resolvedVariableName, options: [])
        }

        return output
    }

    /// Replace any value placeholders with an appropriate value for this variable.
    fileprivate func resolveValues(input: String, values: [String]) -> String {
        var output = input

        // Find things like VALUE_0, VALUE_1, etc. We only care about the number they specified.
        let regex = NSRegularExpression("VALUE_(\\d)")

        while let match = regex.firstMatch(in: output, options: [], range: NSRange(location: 0, length: output.utf16.count)) {
            // Pull out the number that was requested so we can look it up in our values array.
            let range = match.range(at: 1)

            if let swiftRange = Range(range, in: output) {
                let name = Int(output[swiftRange]) ?? 0
                output = output.replacingOccurrences(of: "VALUE_\(name)", with: values[name], options: [])
            }
        }

        return output
    }

    /// Converts a calculation – e.g. 3 * 4 % 2 – into its result. Calculations must be written in a specific way so they can be distinguished from regular text: ${3 * 4 % 2}. Note: we're being lazy here and just piping this into JavaScript.
    fileprivate func resolveCalculations(input: String) -> String {
        guard input.contains("${") else { return input }

        var output = input

        // Look for ${...} and pull out the ... part.
        let pattern = NSRegularExpression("\\$\\{([^\\}]+)\\}")
        let context = JSContext()!

        while let match = pattern.firstMatch(in: output, options: [], range: NSRange(location: 0, length: output.utf16.count)) {
            let range = match.range(at: 1)
            guard let swiftRange = Range(range, in: output) else { continue }
            let textMatch = String(output[swiftRange])

            // Run our calculation through JavaScript core and retrieve the result.
            let value = context.evaluateScript(textMatch).toString() ?? ""
            let matchName = "${\(textMatch)}"

            output = output.replacingOccurrences(of: matchName, with: value)
        }

        return output
    }
}
