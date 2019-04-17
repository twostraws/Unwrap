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
        var parts = components(separatedBy: " ")
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

        // Homogenize brace style.
        replaced = replaced.replacingOccurrences(of: "\n{\n", with: " {\n")
        replaced = replaced.replacingOccurrences(of: "\n}\nelse {\n", with: "\n} else {\n")

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

        // Now do one last pass to remove any excess space from each line; we don't care how they indent.
        let lines = replaced.lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        replaced = lines.joined(separator: "\n")

        return replaced
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
                // So, ensure whatever is before or after their name isn't more letters/numbers.
                replaced = replaced.replacingOccurrences(of: "([^A-Za-z0-9])\(componentName)([^A-Za-z0-9])", with: "$1\(replacementWrapper)\(componentNumber)\(replacementWrapper)$2", options: .regularExpression)
                componentNumber += 1
            } else {
                break
            }
        }

        return replaced
    }
}
