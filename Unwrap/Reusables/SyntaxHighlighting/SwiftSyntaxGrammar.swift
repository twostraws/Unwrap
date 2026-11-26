//
//  SwiftSyntaxGrammar.swift
//  Unwrap
//

import Foundation

// Keeping the Swift lexer's state transitions together makes malformed-input recovery auditable.
// swiftlint:disable file_length
/// A source-preserving lexer for modern Swift, including Swift 6.4 syntax.
///
/// This deliberately works with incomplete fragments because lesson and practice code is not
/// necessarily a complete declaration. It follows maximal-munch rules for literals and operators,
/// then adds lightweight contextual classification for types, calls, members, and SwiftUI code.
nonisolated struct SwiftSyntaxGrammar: SyntaxGrammar { // swiftlint:disable:this type_body_length
    private static let keywords: Set<String> = [
        "Any", "Protocol", "Self", "Type", "_", "actor", "any", "as", "associatedtype", "associativity",
        "async", "await",
        "borrow", "borrowing", "break", "case", "catch", "class", "consume", "consuming", "continue",
        "convenience", "copy", "default", "defer", "deinit", "didSet", "distributed", "do", "dynamic",
        "discard", "each", "else", "enum", "extension", "fallthrough", "false", "fileprivate", "final", "for",
        "func", "get", "guard", "higherThan", "if", "import", "in", "indirect", "infix", "init", "initializes",
        "inout", "internal", "is",
        "isolated", "lazy", "left", "let", "lowerThan", "macro", "modify", "mutate", "mutating", "nil", "none",
        "nonisolated", "nonmutating", "nonsending", "open", "operator", "optional", "override", "package",
        "postfix", "precedence", "precedencegroup", "prefix", "private", "protocol", "public", "read", "repeat",
        "required", "rethrows", "return", "right", "safe", "scoped", "self", "sending", "set", "some",
        "static", "struct", "subscript", "super", "switch", "then", "throw", "throws", "true", "try",
        "typealias", "unowned", "unsafe", "using", "var", "weak", "where", "while", "willSet", "yield",
        "yielding"
    ]

    private static let declarationKeywords: Set<String> = [
        "actor", "associatedtype", "class", "enum", "extension", "protocol", "struct", "typealias"
    ]

    private static let operatorCharacters: Set<Character> = [
        "/", "=", "-", "+", "!", "*", "%", "<", ">", "&", "|", "^", "?", "~", "."
    ]

    private static let regexPrefixKeywords: Set<String> = [
        "as", "await", "case", "catch", "in", "is", "return", "throw", "try", "where", "yield"
    ]

    func tokens(in source: String) -> [SyntaxToken] {
        var tokens = [SyntaxToken]()
        scan(
            source,
            range: source.startIndex..<source.endIndex,
            inheritedScopes: ["source.swift"],
            into: &tokens
        )
        return tokens
    }

    private func scan(
        _ source: String,
        range: Range<String.Index>,
        inheritedScopes: [String],
        into tokens: inout [SyntaxToken]
    ) {
        var index = range.lowerBound

        while index < range.upperBound {
            if source[index...].hasPrefix("//") {
                appendLineComment(
                    in: source,
                    startingAt: &index,
                    limit: range.upperBound,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
            } else if source[index...].hasPrefix("/*") {
                appendBlockComment(
                    in: source,
                    startingAt: &index,
                    limit: range.upperBound,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
            } else if let regexEnd = regexLiteralEnd(in: source, startingAt: index, limit: range.upperBound) {
                append(
                    .regex,
                    range: index..<regexEnd,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = regexEnd
            } else if stringOpening(in: source, at: index, limit: range.upperBound) != nil {
                appendString(
                    in: source,
                    startingAt: &index,
                    limit: range.upperBound,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
            } else if let end = prefixedIdentifierEnd(
                in: source,
                startingAt: index,
                prefix: "@",
                limit: range.upperBound
            ) {
                append(
                    .attribute,
                    range: index..<end,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = end
            } else if let end = prefixedIdentifierEnd(
                in: source,
                startingAt: index,
                prefix: "#",
                limit: range.upperBound
            ) {
                append(
                    .directive,
                    range: index..<end,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = end
            } else if let end = keyPathComponentEnd(in: source, startingAt: index, limit: range.upperBound) {
                append(
                    .property,
                    range: index..<end,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = end
            } else if let end = dollarIdentifierEnd(in: source, startingAt: index, limit: range.upperBound) {
                append(
                    .variable,
                    range: index..<end,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = end
            } else if isDigit(source[index], radix: 10) {
                let end = numberEnd(in: source, startingAt: index, limit: range.upperBound)
                append(
                    .number,
                    range: index..<end,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = end
            } else if source[index] == "`" {
                let end = backtickedIdentifierEnd(in: source, startingAt: index, limit: range.upperBound)
                append(
                    .identifier,
                    range: index..<end,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = end
            } else if isIdentifierHead(source[index]) {
                let end = identifierEnd(in: source, startingAt: index, limit: range.upperBound)
                let word = String(source[index..<end])
                let kind = identifierKind(
                    word,
                    in: source,
                    range: index..<end,
                    scanLimit: range
                )
                append(
                    kind,
                    range: index..<end,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = end
            } else if Self.operatorCharacters.contains(source[index]) {
                let end = operatorEnd(in: source, startingAt: index, limit: range.upperBound)
                append(
                    .operator,
                    range: index..<end,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = end
            } else {
                source.formIndex(after: &index)
            }
        }
    }

    private func appendLineComment(
        in source: String,
        startingAt index: inout String.Index,
        limit: String.Index,
        inheritedScopes: [String],
        into tokens: inout [SyntaxToken]
    ) {
        let start = index
        let isDocumentation = source[index...].hasPrefix("///") || source[index...].hasPrefix("//!")

        while index < limit, source[index].isNewline == false {
            source.formIndex(after: &index)
        }

        append(
            isDocumentation ? .documentationComment : .comment,
            range: start..<index,
            inheritedScopes: inheritedScopes,
            into: &tokens
        )
    }

    private func appendBlockComment(
        in source: String,
        startingAt index: inout String.Index,
        limit: String.Index,
        inheritedScopes: [String],
        into tokens: inout [SyntaxToken]
    ) {
        let start = index
        let isDocumentation = source[index...].hasPrefix("/**") || source[index...].hasPrefix("/*!")
        index = advanced(in: source, from: index, by: 2, limit: limit)
        var depth = 1

        while index < limit, depth > 0 {
            if source[index...].hasPrefix("/*") {
                depth += 1
                index = advanced(in: source, from: index, by: 2, limit: limit)
            } else if source[index...].hasPrefix("*/") {
                depth -= 1
                index = advanced(in: source, from: index, by: 2, limit: limit)
            } else {
                source.formIndex(after: &index)
            }
        }

        append(
            isDocumentation ? .documentationComment : .comment,
            range: start..<index,
            inheritedScopes: inheritedScopes,
            into: &tokens
        )
    }

    private func appendString(
        in source: String,
        startingAt index: inout String.Index,
        limit: String.Index,
        inheritedScopes: [String],
        into tokens: inout [SyntaxToken]
    ) {
        guard let opening = stringOpening(in: source, at: index, limit: limit) else { return }

        let start = index
        var cursor = opening.contentStart
        var segmentStart = start

        while cursor < limit {
            if closesString(
                in: source,
                at: cursor,
                quoteCount: opening.quoteCount,
                hashCount: opening.hashCount,
                limit: limit
            ) {
                let end = advanced(
                    in: source,
                    from: cursor,
                    by: opening.quoteCount + opening.hashCount,
                    limit: limit
                )
                append(
                    .string,
                    range: segmentStart..<end,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                index = end
                return
            }

            if let expressionStart = interpolationExpressionStart(
                in: source,
                at: cursor,
                hashCount: opening.hashCount,
                limit: limit
            ) {
                append(
                    .string,
                    range: segmentStart..<cursor,
                    inheritedScopes: inheritedScopes,
                    into: &tokens
                )
                append(
                    .operator,
                    range: cursor..<expressionStart,
                    inheritedScopes: inheritedScopes + ["interpolation"],
                    into: &tokens
                )

                let closingParenthesis = interpolationClosingParenthesis(
                    in: source,
                    startingAt: expressionStart,
                    limit: limit
                )
                let expressionEnd = closingParenthesis ?? limit
                scan(
                    source,
                    range: expressionStart..<expressionEnd,
                    inheritedScopes: inheritedScopes + ["interpolation"],
                    into: &tokens
                )

                if let closingParenthesis {
                    let afterClosing = source.index(after: closingParenthesis)
                    append(
                        .operator,
                        range: closingParenthesis..<afterClosing,
                        inheritedScopes: inheritedScopes + ["interpolation"],
                        into: &tokens
                    )
                    cursor = afterClosing
                    segmentStart = afterClosing
                    continue
                } else {
                    index = limit
                    return
                }
            }

            if let escapeEnd = escapeSequenceEnd(
                in: source,
                at: cursor,
                hashCount: opening.hashCount,
                limit: limit
            ) {
                cursor = escapeEnd
            } else {
                source.formIndex(after: &cursor)
            }
        }

        append(
            .string,
            range: segmentStart..<limit,
            inheritedScopes: inheritedScopes,
            into: &tokens
        )
        index = limit
    }

    private func interpolationClosingParenthesis(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index? {
        var cursor = start
        var depth = 1

        while cursor < limit {
            if source[cursor...].hasPrefix("//") {
                while cursor < limit, source[cursor].isNewline == false {
                    source.formIndex(after: &cursor)
                }
            } else if source[cursor...].hasPrefix("/*") {
                cursor = blockCommentEnd(in: source, startingAt: cursor, limit: limit)
            } else if let regexEnd = regexLiteralEnd(in: source, startingAt: cursor, limit: limit) {
                cursor = regexEnd
            } else if let opening = stringOpening(in: source, at: cursor, limit: limit) {
                cursor = stringEndWithoutClassification(
                    in: source,
                    opening: opening,
                    limit: limit
                )
            } else if source[cursor] == "(" {
                depth += 1
                source.formIndex(after: &cursor)
            } else if source[cursor] == ")" {
                depth -= 1
                if depth == 0 {
                    return cursor
                }
                source.formIndex(after: &cursor)
            } else {
                source.formIndex(after: &cursor)
            }
        }

        return nil
    }

    private func stringEndWithoutClassification(
        in source: String,
        opening: SwiftStringOpening,
        limit: String.Index
    ) -> String.Index {
        var cursor = opening.contentStart

        while cursor < limit {
            if closesString(
                in: source,
                at: cursor,
                quoteCount: opening.quoteCount,
                hashCount: opening.hashCount,
                limit: limit
            ) {
                return advanced(
                    in: source,
                    from: cursor,
                    by: opening.quoteCount + opening.hashCount,
                    limit: limit
                )
            }

            if let expressionStart = interpolationExpressionStart(
                in: source,
                at: cursor,
                hashCount: opening.hashCount,
                limit: limit
            ) {
                guard let closingParenthesis = interpolationClosingParenthesis(
                    in: source,
                    startingAt: expressionStart,
                    limit: limit
                ) else {
                    return limit
                }
                cursor = source.index(after: closingParenthesis)
            } else if let escapeEnd = escapeSequenceEnd(
                in: source,
                at: cursor,
                hashCount: opening.hashCount,
                limit: limit
            ) {
                cursor = escapeEnd
            } else {
                source.formIndex(after: &cursor)
            }
        }

        return limit
    }

    private func blockCommentEnd(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index {
        var cursor = advanced(in: source, from: start, by: 2, limit: limit)
        var depth = 1

        while cursor < limit, depth > 0 {
            if source[cursor...].hasPrefix("/*") {
                depth += 1
                cursor = advanced(in: source, from: cursor, by: 2, limit: limit)
            } else if source[cursor...].hasPrefix("*/") {
                depth -= 1
                cursor = advanced(in: source, from: cursor, by: 2, limit: limit)
            } else {
                source.formIndex(after: &cursor)
            }
        }

        return cursor
    }

    private func rawRegexEnd(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index? {
        var delimiter = start
        var hashCount = 0

        while delimiter < limit, source[delimiter] == "#" {
            hashCount += 1
            source.formIndex(after: &delimiter)
        }

        guard hashCount > 0, delimiter < limit, source[delimiter] == "/" else { return nil }

        var cursor = source.index(after: delimiter)
        while cursor < limit {
            if source[cursor] == "/" {
                var candidate = source.index(after: cursor)
                var matchedHashes = 0

                while candidate < limit, matchedHashes < hashCount, source[candidate] == "#" {
                    matchedHashes += 1
                    source.formIndex(after: &candidate)
                }

                if matchedHashes == hashCount {
                    return candidate
                }
            }

            source.formIndex(after: &cursor)
        }

        return limit
    }

    private func regexLiteralEnd(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index? {
        if let rawEnd = rawRegexEnd(in: source, startingAt: start, limit: limit) {
            return rawEnd
        }

        guard source[start] == "/",
              canStartBareRegex(in: source, at: start),
              source[start...].hasPrefix("//") == false,
              source[start...].hasPrefix("/*") == false else {
            return nil
        }

        var cursor = source.index(after: start)
        var isEscaped = false
        var isInCharacterClass = false

        while cursor < limit, source[cursor].isNewline == false {
            let character = source[cursor]

            if isEscaped {
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else if character == "[" {
                isInCharacterClass = true
            } else if character == "]" {
                isInCharacterClass = false
            } else if character == "/", isInCharacterClass == false {
                return source.index(after: cursor)
            }

            source.formIndex(after: &cursor)
        }

        return nil
    }

    private func canStartBareRegex(in source: String, at index: String.Index) -> Bool {
        guard index > source.startIndex else { return true }
        var cursor = index

        while cursor > source.startIndex {
            let previous = source.index(before: cursor)
            if source[previous].isWhitespace {
                cursor = previous
            } else {
                let character = source[previous]

                if "([{,:;".contains(character) || Self.operatorCharacters.contains(character) {
                    return true
                }

                guard isIdentifierBody(character) else { return false }
                var wordStart = previous

                while wordStart > source.startIndex {
                    let candidate = source.index(before: wordStart)
                    guard isIdentifierBody(source[candidate]) else { break }
                    wordStart = candidate
                }

                return Self.regexPrefixKeywords.contains(String(source[wordStart...previous]))
            }
        }

        return true
    }

    private func stringOpening(
        in source: String,
        at start: String.Index,
        limit: String.Index
    ) -> SwiftStringOpening? {
        var quote = start
        var hashCount = 0

        while quote < limit, source[quote] == "#" {
            hashCount += 1
            source.formIndex(after: &quote)
        }

        guard quote < limit, source[quote] == "\"" else { return nil }

        let quoteCount = source[quote...].hasPrefix("\"\"\"") ? 3 : 1
        let contentStart = advanced(in: source, from: quote, by: quoteCount, limit: limit)
        return SwiftStringOpening(
            hashCount: hashCount,
            quoteCount: quoteCount,
            contentStart: contentStart
        )
    }

    private func closesString(
        in source: String,
        at index: String.Index,
        quoteCount: Int,
        hashCount: Int,
        limit: String.Index
    ) -> Bool {
        var candidate = index

        for _ in 0..<quoteCount {
            guard candidate < limit, source[candidate] == "\"" else { return false }
            source.formIndex(after: &candidate)
        }

        for _ in 0..<hashCount {
            guard candidate < limit, source[candidate] == "#" else { return false }
            source.formIndex(after: &candidate)
        }

        return true
    }

    private func interpolationExpressionStart(
        in source: String,
        at index: String.Index,
        hashCount: Int,
        limit: String.Index
    ) -> String.Index? {
        guard source[index] == "\\" else { return nil }
        var candidate = source.index(after: index)

        for _ in 0..<hashCount {
            guard candidate < limit, source[candidate] == "#" else { return nil }
            source.formIndex(after: &candidate)
        }

        guard candidate < limit, source[candidate] == "(" else { return nil }
        return source.index(after: candidate)
    }

    private func escapeSequenceEnd(
        in source: String,
        at index: String.Index,
        hashCount: Int,
        limit: String.Index
    ) -> String.Index? {
        guard source[index] == "\\" else { return nil }
        var candidate = source.index(after: index)

        for _ in 0..<hashCount {
            guard candidate < limit, source[candidate] == "#" else { return nil }
            source.formIndex(after: &candidate)
        }

        guard candidate < limit else { return candidate }
        return source.index(after: candidate)
    }

    private func numberEnd(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index {
        var index = start
        var radix = 10

        if source[index] == "0" {
            let prefix = source.index(after: index)
            if prefix < limit {
                switch source[prefix] {
                case "b", "B":
                    radix = 2
                    index = source.index(after: prefix)
                case "o", "O":
                    radix = 8
                    index = source.index(after: prefix)
                case "x", "X":
                    radix = 16
                    index = source.index(after: prefix)
                default:
                    break
                }
            }
        }

        consumeDigits(in: source, radix: radix, index: &index, limit: limit)

        if radix == 10 || radix == 16 {
            consumeFraction(in: source, radix: radix, index: &index, limit: limit)
            consumeExponent(in: source, radix: radix, index: &index, limit: limit)
        }

        return index
    }

    private func consumeDigits(
        in source: String,
        radix: Int,
        index: inout String.Index,
        limit: String.Index
    ) {
        while index < limit, isDigit(source[index], radix: radix) || source[index] == "_" {
            source.formIndex(after: &index)
        }
    }

    private func consumeFraction(
        in source: String,
        radix: Int,
        index: inout String.Index,
        limit: String.Index
    ) {
        guard index < limit, source[index] == "." else { return }
        let firstDigit = source.index(after: index)
        guard firstDigit < limit, isDigit(source[firstDigit], radix: radix) else { return }
        index = firstDigit
        consumeDigits(in: source, radix: radix, index: &index, limit: limit)
    }

    private func consumeExponent(
        in source: String,
        radix: Int,
        index: inout String.Index,
        limit: String.Index
    ) {
        guard index < limit else { return }
        let marker = source[index]
        let isExponent = radix == 10
            ? marker == "e" || marker == "E"
            : marker == "p" || marker == "P"
        guard isExponent else { return }

        var candidate = source.index(after: index)
        if candidate < limit, source[candidate] == "+" || source[candidate] == "-" {
            source.formIndex(after: &candidate)
        }

        let digitsStart = candidate
        consumeDigits(in: source, radix: 10, index: &candidate, limit: limit)
        guard source[digitsStart..<candidate].contains(where: \.isNumber) else { return }
        index = candidate
    }

    private func identifierKind(
        _ word: String,
        in source: String,
        range: Range<String.Index>,
        scanLimit: Range<String.Index>
    ) -> SyntaxTokenKind {
        if Self.keywords.contains(word) {
            return .keyword
        }

        if let previousWord = previousWord(in: source, before: range.lowerBound, limit: scanLimit.lowerBound),
           Self.declarationKeywords.contains(previousWord) {
            return .className
        }

        if let previousCharacter = previousNonWhitespaceCharacter(
            in: source,
            before: range.lowerBound,
            limit: scanLimit.lowerBound
        ), previousCharacter == "." {
            return nextNonWhitespaceCharacter(in: source, after: range.upperBound, limit: scanLimit.upperBound) == "("
                ? .function
                : .property
        }

        if word.first?.isUppercase == true {
            return .className
        }

        if let nextCharacter = nextNonWhitespaceCharacter(
            in: source,
            after: range.upperBound,
            limit: scanLimit.upperBound
        ), nextCharacter == "(" || nextCharacter == "{" {
            return .function
        }

        return .identifier
    }

    private func previousWord(
        in source: String,
        before index: String.Index,
        limit: String.Index
    ) -> String? {
        var cursor = index
        while cursor > limit {
            let previous = source.index(before: cursor)
            if source[previous].isWhitespace {
                cursor = previous
            } else {
                break
            }
        }

        let end = cursor
        while cursor > limit {
            let previous = source.index(before: cursor)
            guard isIdentifierBody(source[previous]) else { break }
            cursor = previous
        }

        guard cursor < end else { return nil }
        return String(source[cursor..<end])
    }

    private func previousNonWhitespaceCharacter(
        in source: String,
        before index: String.Index,
        limit: String.Index
    ) -> Character? {
        var cursor = index
        while cursor > limit {
            let previous = source.index(before: cursor)
            if source[previous].isWhitespace {
                cursor = previous
            } else {
                return source[previous]
            }
        }
        return nil
    }

    private func nextNonWhitespaceCharacter(
        in source: String,
        after index: String.Index,
        limit: String.Index
    ) -> Character? {
        var cursor = index
        while cursor < limit {
            if source[cursor].isWhitespace {
                source.formIndex(after: &cursor)
            } else {
                return source[cursor]
            }
        }
        return nil
    }

    private func prefixedIdentifierEnd(
        in source: String,
        startingAt start: String.Index,
        prefix: Character,
        limit: String.Index
    ) -> String.Index? {
        guard source[start] == prefix else { return nil }
        let bodyStart = source.index(after: start)
        guard bodyStart < limit, isIdentifierHead(source[bodyStart]) else { return nil }
        return identifierEnd(in: source, startingAt: bodyStart, limit: limit)
    }

    private func dollarIdentifierEnd(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index? {
        guard source[start] == "$" else { return nil }
        var cursor = source.index(after: start)
        guard cursor < limit, isIdentifierBody(source[cursor]) else { return nil }
        while cursor < limit, isIdentifierBody(source[cursor]) {
            source.formIndex(after: &cursor)
        }
        return cursor
    }

    private func keyPathComponentEnd(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index? {
        guard source[start] == "\\" else { return nil }
        var cursor = source.index(after: start)
        var hasComponentSeparator = false

        if cursor < limit, source[cursor] == "." {
            hasComponentSeparator = true
            source.formIndex(after: &cursor)
        }

        guard cursor < limit, isIdentifierHead(source[cursor]) else { return nil }
        cursor = identifierEnd(in: source, startingAt: cursor, limit: limit)

        while cursor < limit {
            while cursor < limit, source[cursor] == "?" || source[cursor] == "!" {
                source.formIndex(after: &cursor)
            }

            guard cursor < limit, source[cursor] == "." else { break }
            let componentStart = source.index(after: cursor)
            guard componentStart < limit, isIdentifierHead(source[componentStart]) else { break }
            hasComponentSeparator = true
            cursor = identifierEnd(in: source, startingAt: componentStart, limit: limit)
        }

        return hasComponentSeparator ? cursor : nil
    }

    private func backtickedIdentifierEnd(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index {
        var cursor = source.index(after: start)
        while cursor < limit {
            if source[cursor] == "`" {
                return source.index(after: cursor)
            }
            source.formIndex(after: &cursor)
        }
        return limit
    }

    private func identifierEnd(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index {
        var cursor = start
        while cursor < limit, isIdentifierBody(source[cursor]) {
            source.formIndex(after: &cursor)
        }
        return cursor
    }

    private func operatorEnd(
        in source: String,
        startingAt start: String.Index,
        limit: String.Index
    ) -> String.Index {
        var cursor = start
        while cursor < limit, Self.operatorCharacters.contains(source[cursor]) {
            source.formIndex(after: &cursor)
        }
        return cursor
    }

    private func isIdentifierHead(_ character: Character) -> Bool {
        character == "_" || character.isLetter
    }

    private func isIdentifierBody(_ character: Character) -> Bool {
        isIdentifierHead(character)
            || character.isNumber
    }

    private func isDigit(_ character: Character, radix: Int) -> Bool {
        if let value = character.wholeNumberValue {
            return value < radix
        }
        return radix == 16 && "abcdefABCDEF".contains(character)
    }

    private func append(
        _ kind: SyntaxTokenKind,
        range: Range<String.Index>,
        inheritedScopes: [String],
        into tokens: inout [SyntaxToken]
    ) {
        guard range.isEmpty == false else { return }
        tokens.append(
            SyntaxToken(
                kind: kind,
                range: range,
                scopes: inheritedScopes + [kind.rawValue]
            )
        )
    }

    private func advanced(
        in source: String,
        from index: String.Index,
        by distance: Int,
        limit: String.Index
    ) -> String.Index {
        source.index(index, offsetBy: distance, limitedBy: limit) ?? limit
    }
}
