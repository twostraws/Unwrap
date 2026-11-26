//
//  PracticePlaceholderResolver.swift
//  Unwrap
//

import Foundation

struct PracticePlaceholderResolver {
    struct Context: Equatable {
        var names = [String]()
        var naturalNames = [String]()
        var values = [String]()
        var operators = [String]()
    }

    struct Resolution: Equatable {
        let output: String
        let context: Context
    }

    private let random: any RandomProviding
    private let values: PracticeValueGenerator

    init(random: any RandomProviding) {
        self.random = random
        values = PracticeValueGenerator(random: random)
    }

    func resolve(_ template: String, context initialContext: Context = Context()) throws -> Resolution {
        var context = initialContext
        var output = template

        replaceAll("CONSTANT_OR_VARIABLE", in: &output) {
            values.letOrVar()
        }
        replaceAll("TRUE_OR_FALSE", in: &output) {
            values.boolean()
        }

        var generatedNames = Set<String>()
        while output.contains("RANDOM_INT_NAME") {
            let choice = uniqueIntegerName(excluding: generatedNames)
            generatedNames.insert(choice.name)
            context.names.append(choice.name)
            context.naturalNames.append(choice.naturalName)
            replaceFirst("RANDOM_INT_NAME", with: choice.name, in: &output)
        }

        resolveIntegers(search: "RANDOM_MEDIUM_INT", range: 1...100, output: &output, context: &context)
        resolveIntegers(search: "RANDOM_SMALL_INT", range: 1...10, output: &output, context: &context)
        resolveIntegers(search: "RANDOM_TINY_INT", range: 1...3, output: &output, context: &context)

        var generatedStringNames = Set<String>()
        var possibleStringValues = [[String]]()
        while output.contains("RANDOM_STRING_NAME") {
            let choice = uniqueStringChoice(excluding: generatedStringNames)
            generatedStringNames.insert(choice.name)
            context.names.append(choice.name)
            context.naturalNames.append(choice.naturalName)
            possibleStringValues.append(choice.values)
            replaceFirst("RANDOM_STRING_NAME", with: choice.name, in: &output)
        }

        try resolveStringValues(
            in: &output,
            possibleValues: possibleStringValues,
            generatedStringCount: generatedStringNames.count,
            context: &context
        )

        var generatedBooleanNames = Set<String>()
        while output.contains("RANDOM_BOOL_NAME") {
            let name = uniqueBooleanName(excluding: generatedBooleanNames)
            generatedBooleanNames.insert(name)
            context.names.append(name)
            replaceFirst("RANDOM_BOOL_NAME", with: name, in: &output)
        }

        replaceAll("RANDOM_OPERATOR", in: &output) {
            let value = values.comparisonOperator()
            context.operators.append(value)
            return value
        }

        output = resolveReferences(in: output, context: context)
        output = try resolveCalculations(in: output)

        return Resolution(output: output, context: context)
    }

    func resolveReferences(in template: String, context: Context) -> String {
        var output = template

        for (index, naturalName) in context.naturalNames.enumerated() {
            output = output.replacing(
                "NAME_NATURAL_\(index)|capitalizedFirst",
                with: capitalizingFirst(naturalName)
            )
            output = output.replacing(
                "NAME_NATURAL_\(index)|capitalized",
                with: naturalName.capitalized
            )
            output = output.replacing(
                "NAME_NATURAL_\(index)|count",
                with: String(naturalName.count)
            )
            output = output.replacing("NAME_NATURAL_\(index)", with: naturalName)
        }

        for (index, name) in context.names.enumerated() {
            output = output.replacing("NAME_\(index)", with: name)
        }

        for (index, value) in context.values.enumerated() {
            output = output.replacing("VALUE_\(index)", with: value)
        }

        return output
    }

    func applyingFilter(to value: String) -> String {
        let parts = value.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return value }

        let source = String(parts[0])
        switch parts[1] {
        case "count":
            return String(source.count)
        case "capitalized":
            return source.capitalized
        case "capitalizedFirst":
            return capitalizingFirst(source)
        default:
            return value
        }
    }

    private func uniqueIntegerName(excluding usedNames: Set<String>) -> (name: String, naturalName: String) {
        for _ in 0..<100 {
            let choice = values.integerName()
            if usedNames.contains(choice.name) == false {
                return choice
            }
        }

        let suffix = usedNames.count + 1
        return ("value\(suffix)", "value \(suffix)")
    }

    private func uniqueStringChoice(excluding usedNames: Set<String>) -> PracticeValueGenerator.StringChoice {
        for _ in 0..<100 {
            let choice = values.stringChoice()
            if usedNames.contains(choice.name) == false {
                return choice
            }
        }

        let suffix = usedNames.count + 1
        return PracticeValueGenerator.StringChoice(
            name: "text\(suffix)",
            naturalName: "text \(suffix)",
            values: ["Swift"]
        )
    }

    private func uniqueBooleanName(excluding usedNames: Set<String>) -> String {
        for _ in 0..<100 {
            let name = values.booleanName()
            if usedNames.contains(name) == false {
                return name
            }
        }

        return "isEnabled\(usedNames.count + 1)"
    }

    private func resolveIntegers(
        search: String,
        range: ClosedRange<Int>,
        output: inout String,
        context: inout Context
    ) {
        while output.contains(search) {
            let value = String(random.nextInt(in: range))
            context.values.append(value)
            replaceFirst(search, with: value, in: &output)
        }
    }

    private func resolveStringValues(
        in output: inout String,
        possibleValues: [[String]],
        generatedStringCount: Int,
        context: inout Context
    ) throws {
        var usedValues = Set<String>()

        for index in 0...4 {
            let placeholder = "RANDOM_STRING_VALUE_\(index)"
            while output.contains(placeholder) {
                guard possibleValues.indices.contains(index) else {
                    throw PracticeContentError.invalidContent(placeholder)
                }

                guard let value = possibleValues[index].first(where: { usedValues.contains($0) == false }) else {
                    throw PracticeContentError.invalidContent(placeholder)
                }

                usedValues.insert(value)
                context.values.append(value)
                replaceFirst(placeholder, with: value, in: &output)
            }
        }

        if generatedStringCount > 0, usedValues.isEmpty {
            for values in possibleValues {
                guard let value = values.first else {
                    throw PracticeContentError.invalidContent("RANDOM_STRING_VALUE")
                }
                context.values.append(value)
            }
        }
    }

    private func resolveCalculations(in input: String) throws -> String {
        var output = input
        let expression = try NSRegularExpression(pattern: #"\$\{([^}]+)\}"#)

        while let match = expression.firstMatch(
            in: output,
            range: NSRange(output.startIndex..., in: output)
        ) {
            guard let wholeRange = Range(match.range(at: 0), in: output),
                  let calculationRange = Range(match.range(at: 1), in: output) else {
                throw PracticeContentError.invalidContent(input)
            }

            let calculation = String(output[calculationRange])
            guard let value = IntegerExpression(calculation).evaluate() else {
                throw PracticeContentError.invalidContent(calculation)
            }

            output.replaceSubrange(wholeRange, with: String(value))
        }

        return output
    }

    private func replaceAll(_ target: String, in output: inout String, replacement: () -> String) {
        while output.contains(target) {
            replaceFirst(target, with: replacement(), in: &output)
        }
    }

    private func replaceFirst(_ target: String, with replacement: String, in output: inout String) {
        guard let range = output.range(of: target) else { return }
        output.replaceSubrange(range, with: replacement)
    }

    private func capitalizingFirst(_ input: String) -> String {
        guard let first = input.first else { return input }
        return first.uppercased() + input.dropFirst()
    }
}

private extension PracticePlaceholderResolver {
    final class IntegerExpression {
        private let characters: [Character]
        private var index = 0

        init(_ expression: String) {
            characters = Array(expression)
        }

        func evaluate() -> Int? {
            guard let value = parseExpression() else { return nil }
            skipWhitespace()
            return index == characters.count ? value : nil
        }

        private func parseExpression() -> Int? {
            guard var value = parseTerm() else { return nil }

            while true {
                skipWhitespace()
                if consume("+") {
                    guard let right = parseTerm() else { return nil }
                    let (result, overflowed) = value.addingReportingOverflow(right)
                    guard overflowed == false else { return nil }
                    value = result
                } else if consume("-") {
                    guard let right = parseTerm() else { return nil }
                    let (result, overflowed) = value.subtractingReportingOverflow(right)
                    guard overflowed == false else { return nil }
                    value = result
                } else {
                    return value
                }
            }
        }

        private func parseTerm() -> Int? {
            guard var value = parseFactor() else { return nil }

            while true {
                skipWhitespace()
                if consume("*") {
                    guard let right = parseFactor() else { return nil }
                    let (result, overflowed) = value.multipliedReportingOverflow(by: right)
                    guard overflowed == false else { return nil }
                    value = result
                } else if consume("/") {
                    guard let right = parseFactor(), right != 0 else { return nil }
                    let (result, overflowed) = value.dividedReportingOverflow(by: right)
                    guard overflowed == false else { return nil }
                    value = result
                } else if consume("%") {
                    guard let right = parseFactor(), right != 0 else { return nil }
                    let (result, overflowed) = value.remainderReportingOverflow(dividingBy: right)
                    guard overflowed == false else { return nil }
                    value = result
                } else {
                    return value
                }
            }
        }

        private func parseFactor() -> Int? {
            skipWhitespace()

            if consume("-") {
                guard let value = parseFactor() else { return nil }
                let (result, overflowed) = 0.subtractingReportingOverflow(value)
                return overflowed ? nil : result
            }

            if consume("(") {
                guard let value = parseExpression() else { return nil }
                skipWhitespace()
                return consume(")") ? value : nil
            }

            let start = index
            while index < characters.count, characters[index].isNumber {
                index += 1
            }

            guard start < index else { return nil }
            return Int(String(characters[start..<index]))
        }

        private func skipWhitespace() {
            while index < characters.count, characters[index].isWhitespace {
                index += 1
            }
        }

        private func consume(_ character: Character) -> Bool {
            guard index < characters.count, characters[index] == character else { return false }
            index += 1
            return true
        }
    }
}
