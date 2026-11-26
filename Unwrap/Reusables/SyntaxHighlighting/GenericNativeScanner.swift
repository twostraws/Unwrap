//
//  GenericNativeScanner.swift
//  Unwrap
//

// Keeping the scanner's state transitions together makes malformed-input recovery auditable.
// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
nonisolated struct GenericNativeScanner: Sendable {
    let configuration: Configuration

    static let cStyleOperators = [
        "===", "!==", ">>>=", "<<=", ">>=", "??=", "&&=", "||=", "**=",
        "?->", "=>", "->", "::", "++", "--", "==", "!=", "<=", ">=",
        "&&", "||", "??", "?.", "+=", "-=", "*=", "/=", "%=", "&=",
        "|=", "^=", "<<", ">>>", ">>", "**", "...", "..", "=", "+",
        "-", "*", "/", "%", "<", ">", "!", "&", "|", "^", "~", "?",
        ":", "."
    ]

    static let cStyleStrings = [
        StringDelimiter("\""),
        StringDelimiter("'")
    ]

    static let cStyleBlockComments = [BlockComment("/*", "*/")]

    func tokens(in source: String) -> [SyntaxToken] {
        guard source.isEmpty == false else { return [] }

        var result = [SyntaxToken]()
        var index = source.startIndex
        var previousWord: String?
        var isInsideMarkupTag = false
        var braceDepth = 0

        while index < source.endIndex {
            let character = source[index]

            if character.isWhitespace {
                source.formIndex(after: &index)
                continue
            }

            if character == "{" {
                braceDepth += 1
                source.formIndex(after: &index)
                continue
            }

            if character == "}" {
                braceDepth = max(0, braceDepth - 1)
                source.formIndex(after: &index)
                continue
            }

            if isInsideMarkupTag, character == ">" {
                isInsideMarkupTag = false
                source.formIndex(after: &index)
                continue
            }

            if let comment = matchingBlockComment(in: source, at: index) {
                let start = index
                index = endOfBlockComment(comment, in: source, from: index)
                let kind: SyntaxTokenKind = source[start...].hasPrefix("/**")
                    || source[start...].hasPrefix("/*!")
                    ? .documentationComment
                    : .comment
                result.append(token(kind, start..<index))
                continue
            }

            if matchingLineComment(in: source, at: index) != nil {
                let start = index

                while index < source.endIndex, source[index].isNewline == false {
                    source.formIndex(after: &index)
                }

                let kind: SyntaxTokenKind = source[start...].hasPrefix("///")
                    || source[start...].hasPrefix("//!")
                    ? .documentationComment
                    : .comment
                result.append(token(kind, start..<index))
                continue
            }

            if configuration.recognizesCppRawStrings,
               let rawStringEnd = endOfCppRawString(in: source, from: index) {
                result.append(token(.string, index..<rawStringEnd))
                index = rawStringEnd
                continue
            }

            if let rawStringEnd = endOfRustStyleRawString(in: source, from: index) {
                result.append(token(.string, index..<rawStringEnd))
                index = rawStringEnd
                continue
            }

            if let delimiter = matchingStringDelimiter(in: source, at: index) {
                let start = index
                index = endOfString(delimiter, in: source, from: index)
                let kind: SyntaxTokenKind

                if configuration.stringKeysAreProperties,
                   nextNonWhitespaceIndex(in: source, after: index).map({ source[$0] == ":" }) == true {
                    kind = .property
                } else {
                    kind = .string
                }

                result.append(token(kind, start..<index))
                continue
            }

            if configuration.recognizesMarkupTags,
               let tagRange = markupTagRange(in: source, from: index) {
                result.append(token(.tag, tagRange))
                index = tagRange.upperBound
                isInsideMarkupTag = true
                previousWord = String(source[tagRange])
                continue
            }

            if configuration.recognizesCSSSelectors,
               braceDepth == 0,
               let selectorEnd = endOfPrefixedSelector(in: source, from: index) {
                result.append(token(.selector, index..<selectorEnd))
                index = selectorEnd
                continue
            }

            if let variablePrefix = matchingVariablePrefix(in: source, at: index) {
                let start = index
                index = endOfVariable(
                    in: source,
                    from: index,
                    prefixLength: variablePrefix.count
                )
                let value = normalized(String(source[start..<index]))
                let kind: SyntaxTokenKind = configuration.builtinVariables.contains(value)
                    ? .builtin
                    : .variable
                result.append(token(kind, start..<index))
                continue
            }

            if character == "@", let wordEnd = endOfAtWord(in: source, from: index) {
                let value = normalized(String(source[index..<wordEnd]))
                let kind: SyntaxTokenKind = configuration.keywords.contains(value) ? .keyword : .attribute
                result.append(token(kind, index..<wordEnd))
                previousWord = value
                index = wordEnd
                continue
            }

            if configuration.recognizesHashDirectives,
               character == "#",
               let directiveEnd = endOfHashDirective(in: source, from: index) {
                result.append(token(.directive, index..<directiveEnd))
                previousWord = normalized(String(source[index..<directiveEnd]))
                index = directiveEnd
                continue
            }

            if character.isNumber || isFractionBeginning(in: source, at: index) {
                let end = endOfNumber(in: source, from: index)
                result.append(token(.number, index..<end))
                index = end
                continue
            }

            if isIdentifierStart(character) {
                let start = index
                index = endOfIdentifier(in: source, from: index)
                let sourceWord = String(source[start..<index])
                let word = normalized(sourceWord)
                let kind = identifierKind(
                    previousWord: previousWord,
                    range: start..<index,
                    source: source,
                    isInsideMarkupTag: isInsideMarkupTag,
                    braceDepth: braceDepth
                )
                result.append(token(kind, start..<index))
                previousWord = word
                continue
            }

            if configuration.recognizesSlashRegexLiterals,
               character == "/",
               isLikelyRegexStart(in: source, at: index) {
                let end = endOfSlashRegex(in: source, from: index)
                result.append(token(.regex, index..<end))
                index = end
                continue
            }

            if let operatorValue = matchingOperator(in: source, at: index) {
                let end = advanced(index, by: operatorValue.count, in: source)
                result.append(token(.operator, index..<end))
                index = end
                continue
            }

            if Self.operatorCharacters.contains(character) {
                let end = source.index(after: index)
                result.append(token(.operator, index..<end))
                index = end
                continue
            }

            source.formIndex(after: &index)
        }

        return result
    }

    private func token(
        _ kind: SyntaxTokenKind,
        _ range: Range<String.Index>,
        additionalScopes: [String] = []
    ) -> SyntaxToken {
        SyntaxToken(
            kind: kind,
            range: range,
            scopes: ["source.\(configuration.language.rawValue)", kind.rawValue] + additionalScopes
        )
    }

    private func normalized(_ value: String) -> String {
        configuration.isCaseInsensitive ? value.lowercased() : value
    }

    private func matchingLineComment(in source: String, at index: String.Index) -> String? {
        configuration.lineCommentMarkers.first { source[index...].hasPrefix($0) }
    }

    private func matchingBlockComment(
        in source: String,
        at index: String.Index
    ) -> BlockComment? {
        configuration.blockComments.first { source[index...].hasPrefix($0.opening) }
    }

    private func matchingStringDelimiter(
        in source: String,
        at index: String.Index
    ) -> StringDelimiter? {
        configuration.stringDelimiters.first { source[index...].hasPrefix($0.opening) }
    }

    private func matchingVariablePrefix(in source: String, at index: String.Index) -> String? {
        configuration.variablePrefixes.first { source[index...].hasPrefix($0) }
    }

    private func matchingOperator(in source: String, at index: String.Index) -> String? {
        configuration.operators.first { candidate in
            if source[index...].hasPrefix(candidate) {
                return true
            }

            guard configuration.isCaseInsensitive else { return false }
            let end = advanced(index, by: candidate.count, in: source)
            return source[index..<end].lowercased() == candidate.lowercased()
        }
    }

    private func endOfBlockComment(
        _ comment: BlockComment,
        in source: String,
        from start: String.Index
    ) -> String.Index {
        var index = advanced(start, by: comment.opening.count, in: source)
        var depth = 1

        while index < source.endIndex {
            if comment.allowsNesting, source[index...].hasPrefix(comment.opening) {
                depth += 1
                index = advanced(index, by: comment.opening.count, in: source)
            } else if source[index...].hasPrefix(comment.closing) {
                depth -= 1
                index = advanced(index, by: comment.closing.count, in: source)

                if depth == 0 {
                    return index
                }
            } else {
                source.formIndex(after: &index)
            }
        }

        return source.endIndex
    }

    private func endOfString(
        _ delimiter: StringDelimiter,
        in source: String,
        from start: String.Index
    ) -> String.Index {
        var index = advanced(start, by: delimiter.opening.count, in: source)

        while index < source.endIndex {
            if let escapeCharacter = delimiter.escapeCharacter,
               source[index] == escapeCharacter {
                source.formIndex(after: &index)

                if index < source.endIndex {
                    source.formIndex(after: &index)
                }

                continue
            }

            if source[index...].hasPrefix(delimiter.closing) {
                let closingEnd = advanced(index, by: delimiter.closing.count, in: source)

                if delimiter.doublesClosingDelimiter,
                   closingEnd < source.endIndex,
                   source[closingEnd...].hasPrefix(delimiter.closing) {
                    index = advanced(closingEnd, by: delimiter.closing.count, in: source)
                    continue
                }

                return closingEnd
            }

            if delimiter.allowsNewlines == false, source[index].isNewline {
                return index
            }

            source.formIndex(after: &index)
        }

        return source.endIndex
    }

    private func endOfRustStyleRawString(
        in source: String,
        from start: String.Index
    ) -> String.Index? {
        var index = start

        if source[index...].hasPrefix("br") {
            index = advanced(index, by: 2, in: source)
        } else if source[index] == "r" {
            source.formIndex(after: &index)
        } else {
            return nil
        }

        var hashCount = 0

        while index < source.endIndex, source[index] == "#" {
            hashCount += 1
            source.formIndex(after: &index)
        }

        guard index < source.endIndex, source[index] == "\"" else { return nil }
        source.formIndex(after: &index)

        while index < source.endIndex {
            guard source[index] == "\"" else {
                source.formIndex(after: &index)
                continue
            }

            var candidate = source.index(after: index)
            var matchedHashes = 0

            while candidate < source.endIndex,
                  matchedHashes < hashCount,
                  source[candidate] == "#" {
                matchedHashes += 1
                source.formIndex(after: &candidate)
            }

            if matchedHashes == hashCount {
                return candidate
            }

            source.formIndex(after: &index)
        }

        return source.endIndex
    }

    private func endOfCppRawString(
        in source: String,
        from start: String.Index
    ) -> String.Index? {
        let prefixes = ["u8R\"", "uR\"", "UR\"", "LR\"", "R\""]
        guard let prefix = prefixes.first(where: { source[start...].hasPrefix($0) }) else {
            return nil
        }

        var cursor = advanced(start, by: prefix.count, in: source)
        let delimiterStart = cursor

        while cursor < source.endIndex, source[cursor] != "(" {
            guard source[delimiterStart..<cursor].count < 16,
                  source[cursor].isWhitespace == false,
                  source[cursor] != "\\",
                  source[cursor] != ")" else {
                return nil
            }
            source.formIndex(after: &cursor)
        }

        guard cursor < source.endIndex else { return nil }
        let delimiter = String(source[delimiterStart..<cursor])
        let closing = ")\(delimiter)\""
        source.formIndex(after: &cursor)

        guard let closingRange = source.range(
            of: closing,
            range: cursor..<source.endIndex
        ) else {
            return source.endIndex
        }

        return closingRange.upperBound
    }

    private func markupTagRange(
        in source: String,
        from start: String.Index
    ) -> Range<String.Index>? {
        guard source[start] == "<" else { return nil }
        var index = source.index(after: start)

        if index < source.endIndex, source[index] == "/" {
            source.formIndex(after: &index)
        }

        guard index < source.endIndex, isIdentifierStart(source[index]) else { return nil }
        let nameStart = index
        index = endOfIdentifier(in: source, from: index)
        return nameStart..<index
    }

    private func endOfPrefixedSelector(
        in source: String,
        from start: String.Index
    ) -> String.Index? {
        guard source[start] == "." || source[start] == "#" else { return nil }
        let identifierStart = source.index(after: start)

        guard identifierStart < source.endIndex,
              isIdentifierStart(source[identifierStart]) else {
            return nil
        }

        return endOfIdentifier(in: source, from: identifierStart)
    }

    private func endOfVariable(
        in source: String,
        from start: String.Index,
        prefixLength: Int
    ) -> String.Index {
        var index = advanced(start, by: prefixLength, in: source)
        guard index < source.endIndex else { return index }

        if source[index] == "{" {
            source.formIndex(after: &index)
            var depth = 1

            while index < source.endIndex, depth > 0 {
                if source[index] == "{" {
                    depth += 1
                } else if source[index] == "}" {
                    depth -= 1
                }

                source.formIndex(after: &index)
            }

            return index
        }

        if Self.specialVariableCharacters.contains(source[index]) {
            return source.index(after: index)
        }

        while index < source.endIndex, isIdentifierBody(source[index]) {
            source.formIndex(after: &index)
        }

        return index
    }

    private func endOfAtWord(in source: String, from start: String.Index) -> String.Index? {
        var index = source.index(after: start)
        guard index < source.endIndex, isIdentifierStart(source[index]) else { return nil }
        index = endOfIdentifier(in: source, from: index)
        return index
    }

    private func endOfHashDirective(in source: String, from start: String.Index) -> String.Index? {
        var index = source.index(after: start)
        guard index < source.endIndex, isIdentifierStart(source[index]) else { return nil }
        index = endOfIdentifier(in: source, from: index)
        return index
    }

    private func endOfIdentifier(in source: String, from start: String.Index) -> String.Index {
        var index = start

        while index < source.endIndex, isIdentifierBody(source[index]) {
            source.formIndex(after: &index)
        }

        return index
    }

    private func identifierKind(
        previousWord: String?,
        range: Range<String.Index>,
        source: String,
        isInsideMarkupTag: Bool,
        braceDepth: Int
    ) -> SyntaxTokenKind {
        let sourceWord = String(source[range])
        let word = normalized(sourceWord)

        if configuration.keywords.contains(word) {
            return .keyword
        }

        if configuration.functions.contains(word) {
            return .function
        }

        if configuration.builtins.contains(word) {
            return .builtin
        }

        if configuration.booleans.contains(word) {
            return .boolean
        }

        if isInsideMarkupTag {
            return .attribute
        }

        if let previousWord,
           configuration.typeDeclarationKeywords.contains(previousWord) {
            return .className
        }

        if let colonKind = configuration.identifiersBeforeColon,
           configuration.colonClassificationRequiresBraces == false || braceDepth > 0,
           nextNonWhitespaceIndex(in: source, after: range.upperBound).map({ source[$0] == ":" }) == true {
            return colonKind
        }

        if configuration.recognizesCSSSelectors, braceDepth == 0 {
            return .selector
        }

        let nextCharacter = nextNonWhitespaceIndex(in: source, after: range.upperBound)
            .map { source[$0] }
        let isDeclaredFunction = previousWord.map {
            configuration.functionDeclarationKeywords.contains($0)
        } ?? false
        let isCall = nextCharacter == "("
            || configuration.classifiesCallsBeforeBracesAsFunctions && nextCharacter == "{"

        if isDeclaredFunction || isCall {
            return .function
        }

        if configuration.classNames.contains(word)
            || configuration.classifiesCapitalizedIdentifiersAsClasses
                && sourceWord.first?.isUppercase == true {
            return .className
        }

        if previousNonWhitespaceCharacter(in: source, before: range.lowerBound) == "." {
            return .property
        }

        return .identifier
    }

    private func isFractionBeginning(in source: String, at index: String.Index) -> Bool {
        guard source[index] == "." else { return false }
        let next = source.index(after: index)
        return next < source.endIndex && source[next].isNumber
    }

    private func endOfNumber(in source: String, from start: String.Index) -> String.Index {
        var index = start

        if source[index] == "." {
            source.formIndex(after: &index)
            consumeDecimalDigits(in: source, index: &index)
            consumeExponent(in: source, markers: ["e", "E"], index: &index)
            return consumeNumericSuffix(in: source, index: index)
        }

        if source[index...].hasPrefix("0x") || source[index...].hasPrefix("0X") {
            index = advanced(index, by: 2, in: source)
            consumeHexadecimalDigits(in: source, index: &index)

            if index < source.endIndex, source[index] == "." {
                let next = source.index(after: index)

                if next < source.endIndex, isHexadecimalDigit(source[next]) {
                    index = next
                    consumeHexadecimalDigits(in: source, index: &index)
                }
            }

            consumeExponent(in: source, markers: ["p", "P"], index: &index)
            return consumeNumericSuffix(in: source, index: index)
        }

        if source[index...].hasPrefix("0b") || source[index...].hasPrefix("0B") {
            index = advanced(index, by: 2, in: source)

            while index < source.endIndex,
                  source[index] == "0" || source[index] == "1" || source[index] == "_" {
                source.formIndex(after: &index)
            }

            return consumeNumericSuffix(in: source, index: index)
        }

        if source[index...].hasPrefix("0o") || source[index...].hasPrefix("0O") {
            index = advanced(index, by: 2, in: source)

            while index < source.endIndex,
                  "01234567_".contains(source[index]) {
                source.formIndex(after: &index)
            }

            return consumeNumericSuffix(in: source, index: index)
        }

        consumeDecimalDigits(in: source, index: &index)

        if index < source.endIndex, source[index] == "." {
            let next = source.index(after: index)

            if next < source.endIndex, source[next].isNumber {
                index = next
                consumeDecimalDigits(in: source, index: &index)
            }
        }

        consumeExponent(in: source, markers: ["e", "E"], index: &index)
        return consumeNumericSuffix(in: source, index: index)
    }

    private func consumeDecimalDigits(in source: String, index: inout String.Index) {
        while index < source.endIndex,
              source[index].isNumber || source[index] == "_" {
            source.formIndex(after: &index)
        }
    }

    private func consumeHexadecimalDigits(in source: String, index: inout String.Index) {
        while index < source.endIndex,
              isHexadecimalDigit(source[index]) || source[index] == "_" {
            source.formIndex(after: &index)
        }
    }

    private func consumeExponent(
        in source: String,
        markers: Set<Character>,
        index: inout String.Index
    ) {
        guard index < source.endIndex, markers.contains(source[index]) else { return }
        var candidate = source.index(after: index)

        if candidate < source.endIndex,
           source[candidate] == "+" || source[candidate] == "-" {
            source.formIndex(after: &candidate)
        }

        let digitsStart = candidate
        consumeDecimalDigits(in: source, index: &candidate)

        if candidate > digitsStart {
            index = candidate
        }
    }

    private func consumeNumericSuffix(in source: String, index: String.Index) -> String.Index {
        var index = index

        while index < source.endIndex,
              source[index].isLetter || source[index].isNumber {
            source.formIndex(after: &index)
        }

        return index
    }

    private func isHexadecimalDigit(_ character: Character) -> Bool {
        character.isNumber || "abcdefABCDEF".contains(character)
    }

    private func isLikelyRegexStart(in source: String, at index: String.Index) -> Bool {
        guard source[index] == "/" else { return false }
        guard let previousIndex = previousNonWhitespaceIndex(in: source, before: index) else {
            return true
        }
        let previous = source[previousIndex]

        if let previousIdentifier = previousIdentifier(in: source, before: index),
           configuration.regexPrefixKeywords.contains(normalized(previousIdentifier)) {
            return true
        }

        if previous == ">",
           previousNonWhitespaceCharacter(in: source, before: previousIndex) == "=" {
            return true
        }

        if previous == "+" || previous == "-",
           previousNonWhitespaceCharacter(in: source, before: previousIndex) == previous {
            return false
        }

        return "=([{,:;!&|?+*-".contains(previous)
    }

    private func previousIdentifier(in source: String, before end: String.Index) -> String? {
        guard let lastIndex = previousNonWhitespaceIndex(in: source, before: end),
              isIdentifierBody(source[lastIndex]) else {
            return nil
        }

        var start = lastIndex

        while start > source.startIndex {
            let candidate = source.index(before: start)
            guard isIdentifierBody(source[candidate]) else { break }
            start = candidate
        }

        return String(source[start...lastIndex])
    }

    private func endOfSlashRegex(in source: String, from start: String.Index) -> String.Index {
        var index = source.index(after: start)
        var isInsideCharacterClass = false

        while index < source.endIndex {
            if source[index] == "\\" {
                source.formIndex(after: &index)

                if index < source.endIndex {
                    source.formIndex(after: &index)
                }

                continue
            }

            if source[index] == "[" {
                isInsideCharacterClass = true
            } else if source[index] == "]" {
                isInsideCharacterClass = false
            } else if source[index] == "/", isInsideCharacterClass == false {
                source.formIndex(after: &index)

                while index < source.endIndex, source[index].isLetter {
                    source.formIndex(after: &index)
                }

                return index
            }

            source.formIndex(after: &index)
        }

        return source.endIndex
    }

    private func nextNonWhitespaceIndex(
        in source: String,
        after start: String.Index
    ) -> String.Index? {
        var index = start

        while index < source.endIndex, source[index].isWhitespace {
            source.formIndex(after: &index)
        }

        return index < source.endIndex ? index : nil
    }

    private func previousNonWhitespaceCharacter(
        in source: String,
        before end: String.Index
    ) -> Character? {
        previousNonWhitespaceIndex(in: source, before: end).map { source[$0] }
    }

    private func previousNonWhitespaceIndex(
        in source: String,
        before end: String.Index
    ) -> String.Index? {
        guard end > source.startIndex else { return nil }
        var index = source.index(before: end)

        while true {
            if source[index].isWhitespace == false {
                return index
            }

            guard index > source.startIndex else { return nil }
            source.formIndex(before: &index)
        }
    }

    private func isIdentifierStart(_ character: Character) -> Bool {
        character.isLetter
            || character == "_"
            || configuration.additionalIdentifierStartCharacters.contains(character)
    }

    private func isIdentifierBody(_ character: Character) -> Bool {
        isIdentifierStart(character)
            || character.isNumber
            || configuration.additionalIdentifierBodyCharacters.contains(character)
    }

    private func advanced(
        _ index: String.Index,
        by distance: Int,
        in source: String
    ) -> String.Index {
        source.index(index, offsetBy: distance, limitedBy: source.endIndex) ?? source.endIndex
    }

    private static let operatorCharacters: Set<Character> = [
        "=", "+", "-", "*", "/", "%", "<", ">", "!", "&", "|", "^", "~", "?", ":", "."
    ]

    private static let specialVariableCharacters: Set<Character> = [
        "@", "*", "#", "?", "-", "$", "!"
    ]
}
