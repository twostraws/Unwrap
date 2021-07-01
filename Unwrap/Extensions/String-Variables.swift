//
//  String-Variables.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

extension String {
    /// Converts a string such as "this is a test" into camel case, making "thisIsATest".
    func formatAsVariable() -> String {
        let parts = components(separatedBy: " ")
        var output = parts[0].lowercased()

        for part in parts.dropFirst() {
            output += part.capitalized
        }

        return output
    }

    /// An epic series of replacements to make some piece of code homogenized and anonymized so that variable names, function names, whitespace, etc, don't matter.
    func toAnonymizedVariables() -> String {
        var replaced = self.trimmingCharacters(in: .whitespacesAndNewlines)

        if replaced.isEmpty {
            return replaced
        }

        // Homogenize guard statement to reduce the number of possible solutions
        replaced = homogenizeGuardStatements()

        // Homogenize trailing closures: array.map { … } is always preferred to array.map({ … })
        replaced = replaced.replacingOccurrences(of: #"\(\{(.*?)\}\)"#, with: "{$1}", options: .regularExpression)

        // Homogenize modulus to use %
        replaced = replaced.replacingOccurrences(of: #"\.isMultiple\(of: *(\d+)\)"#, with: " % $1 == 0", options: .regularExpression)

        // Replace .first with [0] to reduce the number of possible solutions
        replaced = replaced.replacingOccurrences(of: ".first", with: "[0]")

        // Homogenize brace style.
        replaced = replaced.replacingOccurrences(of: "\n{\n", with: " {\n")
        replaced = replaced.replacingOccurrences(of: "\n}\nelse {\n", with: "\n} else {\n")

        // Homogenize statements with the optionalreturn keyword
        replaced = replaced.solveOptionalReturnStatements()

        // Always place a line break immediately after an opening brace
        replaced = replaced.replacingOccurrences(of: "\\{(.)", with: "{\n$1", options: .regularExpression)

        // Make sure there's a line break immediately before a closing brace
        replaced = replaced.replacingOccurrences(of: "(.)\\}", with: "$1\n}", options: .regularExpression)

        // Strip any whitespace off the start of lines…
        replaced = replaced.replacingOccurrences(of: "\n[ \t]*", with: "\n", options: .regularExpression)

        // …and the end of lines
        replaced = replaced.replacingOccurrences(of: "[ \t]*\n", with: "\n", options: .regularExpression)

        // Replace semi-colons with line breaks in the unlikely event folks try to put multiple statements on a single line.
        replaced = replaced.replacingOccurrences(of: ";", with: "\n")

        // Add spacing around range operators to avoid false positives that a full stop before a variable is a property access
        replaced = replaced.replacingOccurrences(of: "...", with: " ... ")
        replaced = replaced.replacingOccurrences(of: "..<", with: " ..< ")

        // Some folks, particularly those coming from Python, use Range(1...100) or (1...100) rather than just 1...100. This is legal, so we homogenize it to a regular Swift range.
        replaced = replaced.replacingOccurrences(of: #"Range\((\d+ \.\.\< \d+)\)"#, with: "$1", options: .regularExpression)
        replaced = replaced.replacingOccurrences(of: #"Range\((\d+ \.\.\. \d+)\)"#, with: "$1", options: .regularExpression)
        replaced = replaced.replacingOccurrences(of: #"\((\d+ \.\.\< \d+)\)"#, with: "$1", options: .regularExpression)
        replaced = replaced.replacingOccurrences(of: #"\((\d+ \.\.\. \d+)\)"#, with: "$1", options: .regularExpression)

        // Anonymize variable names.
        replaced = replaced.anonymizingComponent("(?:let|var) ([A-Za-z_][A-Za-z0-9_]*)( =|:)", replacementWrapper: "&")

        // Anonymize loop variable names.
        replaced = replaced.anonymizingComponent("for ([A-Za-z_][A-Za-z0-9_]*) in", replacementWrapper: "@")

        // Anonymize function parameters.
        replaced = replaced.anonymizingComponent("func +[A-Za-z_][A-Za-z0-9_]* *\\((?:([A-Za-z_]*[A-Za-z0-9_]* *[A-Za-z_][A-Za-z0-9_]*) *: *[A-Za-z_][A-Za-z0-9_]*,? *)*", replacementWrapper: "%")

        // Anonymize a closure parameter if one was provided. (This only handles single parameters, but that's enough here.)
        replaced = replaced.anonymizingComponent("\\{\n+([A-Za-z_][A-Za-z0-9_]*) in", replacementWrapper: "§")

        // Anonymize function names.
        replaced = replaced.anonymizingComponent("func +([A-Za-z_][A-Za-z0-9_]*)", replacementWrapper: "#")

        // Remove any extra spaces.
        for _ in 1...3 {
            replaced = replaced.replacingOccurrences(of: "  ", with: " ")
        }

        // Remove any completely blank lines.
        replaced = replaced.lines.filter { !$0.isEmpty }.joined(separator: "\n")

        // Always prefer shorthand data types.
        replaced = replaced.replacingOccurrences(of: "Array<Int>", with: "[Int]")
        replaced = replaced.replacingOccurrences(of: "Array<String>", with: "[String]")
        replaced = replaced.replacingOccurrences(of: "Array<Double>", with: "[Double]")

        replaced = replaced.replacingOccurrences(of: "Dictionary<String, String>", with: "[String: String]")
        replaced = replaced.replacingOccurrences(of: "Dictionary<String, Int>", with: "[String: Int]")
        replaced = replaced.replacingOccurrences(of: "Dictionary<String, Double>", with: "[String: Double]")

        // If folks use explicit type annotation for a collection backed up by an empty initializer, prefer removing the annotation.
        replaced = replaced.replacingOccurrences(of: #":\[([A-Za-z]+)\] *= *\[\]"#, with: " = [$1]()", options: .regularExpression)

        // Now do one last pass to remove any excess space from each line; we don't care how they indent.
        let lines = replaced.lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        replaced = lines.joined(separator: "\n")

        return replaced
    }

    /// A replacement of the optionalreturn keyword with a space. This gives us some extra flexibility to answers without needing to add extra ones.
    func solveOptionalReturnStatements() -> String {
        var replaced = self.trimmingCharacters(in: .whitespacesAndNewlines)

        if replaced.isEmpty {
            return replaced
        }

        replaced = replaced.replacingOccurrences(of: "\\ *optionalreturn *", with: " ", options: .regularExpression)

        return replaced
    }

    /**
     Homogenize guard statements in code to reduce the number of possible solutions
     
     If an else statement of each guard is suitable for expression in one line, new lines after { and before } and extra spaces in the else block will be removed.
     - parameter code: code
     - returns: Homogenized statement
     # Example #
     ```
     guard ... else {  \n return     something   \n   } will be changed to guard ... else { return something }
     guard ... else {  \n return                 \n   } will be changed to guard ... else { return }
     guard ... else {\n   continue    \n              } will be changed to guard ... else { continue }
     ```
     */
    func homogenizeGuardStatements() -> String {
        var replaced = self

        replaced = replacingOccurrences(of: #"else *\{ *\n *return"#,
                                        with: "else { return",
                                        in: replaced,
                                        rangeRegexPattern: #"guard[ \w.()!=&|\n\t\\"\[\]]*else *\{ *\n *return *\w* *\n *\}"#)

        replaced = replacingOccurrences(of: #"else *\{ *\n *continue"#,
                                        with: "else { continue",
                                        in: replaced,
                                        rangeRegexPattern: #"guard[ \w.()!=&|\n\t\\"\[\]]*else *\{ *\n *continue *\w* *\n *\}"#)

        replaced = replacingOccurrences(of: #" *\n *\}"#,
                                        with: " }",
                                        in: replaced,
                                        rangeRegexPattern: #"guard[ \w.()!=&|\n\t\\"\[\]]*else *\{ *(return|continue) *\w* *\n *\}"#)

        replaced = replacingOccurrences(of: #" {2,}"#,
                                        with: " ",
                                        in: replaced,
                                        rangeRegexPattern: #"guard[ \w.()!=&|\n\t\\"\[\]]*else *\{ *(return|continue) *\w* *\}"#)

        return replaced
    }

    /**
     Replaces all occurrences of a target regex with a replacement in text parts that are the same as a range regex.
     
     - parameter targetRegexPattern: regex pattern for replace
     - parameter replacement: replacement text
     - parameter text: text in which we want to make changes
     - parameter rangeRegexPattern: regex pattern to find the parts of the text where the replacement will be made
     - returns: new text
     */
    fileprivate func replacingOccurrences(of targetRegexPattern: String, with replacement: String, in text: String, rangeRegexPattern: String) -> String {

        var result = text

        // Calculate a range regex and its matches in the result.
        guard let rangeRegex = try? NSRegularExpression(pattern: rangeRegexPattern, options: []) else { return text }
        let rangeMatches = rangeRegex.matches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count))

        // This is a counter of a recalculated matches from loop.
        var recalculatedMatchesCount = 0

        // Loop over the range matches and in each iteration recalculates the range and makes changes to the result with that recalculated range.
        for index in rangeMatches.indices {

            // The result could be changed and we need to get new matches with a new length of result otherwise we could get an error.
            let recalculatedMatches = rangeRegex.matches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count))

            // In the first iteration, set the recalculated matches counter to the initial value.
            if index == 0 {
                recalculatedMatchesCount = recalculatedMatches.count
            }

            // Get a recalculated range from the recalculated regex matches.
            // In some cases, the change in the result affects the number of matches found (there will be a loss in the previous iteration of the processed match due to the incorporated changes). In this case, the number of matches will be reduced and we must work with the match on index 0 in the current iteration.
            let i = recalculatedMatches.count == recalculatedMatchesCount ? index : 0
            let range = Range(recalculatedMatches[i].range, in: result)

            // Set the recalculated matches counter to the current value.
            recalculatedMatchesCount = recalculatedMatches.count

            // Make changes to the result with the recalculated range.
            result = result.replacingOccurrences(of: targetRegexPattern, with: replacement, options: .regularExpression, range: range)
        }
        return result
    }

    /// Replaces one instances of a search with a replacement wrapper. For example, it might be asked to replace all variable names using a replacement wrapper &, so it will replace "foo", "bar", and "baz" with &1&, &2&, and &3&.
    fileprivate func anonymizingComponent(_ regexString: String, replacementWrapper: String) -> String {
        let regex = NSRegularExpression(regexString)

        // This is a unique counter between the replacement wrappers, so that each anonymized replacement is unique: &1&, &2&, etc.
        var componentNumber = 1
        var replaced = self

        // Loop over one variable at a time until we're done.
        while let match = regex.firstMatch(in: replaced, options: [], range: NSRange(location: 0, length: replaced.utf16.count)) {
            let range = match.range(at: 1)

            if let swiftRange = Range(range, in: replaced) {
                var componentName = String(replaced[swiftRange])

                // If this has a space inside, it's probably an external parameter name; collapse it to use only internal.
                if componentName.contains(" ") {
                    // Replace the original instance of double naming.
                    replaced = replaced.replacingOccurrences(of: componentName, with: "\(replacementWrapper)\(componentNumber)\(replacementWrapper)")

                    // Now continue using only the internal name.
                    componentName = componentName.components(separatedBy: " ").last!
                }

                // We don't want to just do a simple string replace, because they might call their thing "a" and that would be replaced everywhere.
                // So, ensure whatever is before or after their name isn't more letters/numbers, and it isn't preceded by a full stop.
                replaced = replaced.replacingOccurrences(of: "([^A-Za-z0-9.])\(componentName)([^A-Za-z0-9]|$)", with: "$1\(replacementWrapper)\(componentNumber)\(replacementWrapper)$2", options: .regularExpression)
                componentNumber += 1
            } else {
                break
            }
        }

        return replaced
    }
}
