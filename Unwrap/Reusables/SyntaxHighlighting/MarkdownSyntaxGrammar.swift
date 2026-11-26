//
//  MarkdownSyntaxGrammar.swift
//  Unwrap
//

import Foundation

nonisolated struct MarkdownSyntaxGrammar: SyntaxGrammar {
    func tokens(in source: String) -> [SyntaxToken] {
        guard source.isEmpty == false else { return [] }

        var result = [SyntaxToken]()
        var index = source.startIndex

        while index < source.endIndex {
            if isLineStart(index, in: source),
               let headingEnd = headingEnd(in: source, from: index) {
                result.append(token(.title, range: index..<headingEnd))
                index = headingEnd
                continue
            }

            if isLineStart(index, in: source),
               let marker = fenceMarker(in: source, at: index) {
                let fenceEnd = endOfFence(marker, in: source, from: index)
                result.append(token(.code, range: index..<fenceEnd))
                index = fenceEnd
                continue
            }

            if source[index...].hasPrefix("``"),
               let end = endOfDelimited("``", in: source, from: index) {
                result.append(token(.code, range: index..<end))
                index = end
                continue
            }

            if source[index] == "`",
               let end = endOfDelimited("`", in: source, from: index) {
                result.append(token(.code, range: index..<end))
                index = end
                continue
            }

            if source[index...].hasPrefix("**"),
               let end = endOfDelimited("**", in: source, from: index) {
                result.append(token(.bold, range: index..<end))
                index = end
                continue
            }

            if source[index...].hasPrefix("__"),
               let end = endOfDelimited("__", in: source, from: index) {
                result.append(token(.bold, range: index..<end))
                index = end
                continue
            }

            if source[index] == "*",
               let end = endOfDelimited("*", in: source, from: index) {
                result.append(token(.italic, range: index..<end))
                index = end
                continue
            }

            if source[index] == "_",
               let end = endOfDelimited("_", in: source, from: index) {
                result.append(token(.italic, range: index..<end))
                index = end
                continue
            }

            source.formIndex(after: &index)
        }

        return result
    }

    private func token(
        _ kind: SyntaxTokenKind,
        range: Range<String.Index>
    ) -> SyntaxToken {
        SyntaxToken(
            kind: kind,
            range: range,
            scopes: ["source.markdown", kind.rawValue]
        )
    }

    private func isLineStart(_ index: String.Index, in source: String) -> Bool {
        index == source.startIndex || source[source.index(before: index)].isNewline
    }

    private func headingEnd(in source: String, from start: String.Index) -> String.Index? {
        var index = start
        var count = 0

        while index < source.endIndex, source[index] == "#", count < 6 {
            count += 1
            source.formIndex(after: &index)
        }

        guard count > 0, index < source.endIndex, source[index].isWhitespace else {
            return nil
        }

        return lineEnd(in: source, from: index)
    }

    private func fenceMarker(in source: String, at index: String.Index) -> String? {
        if source[index...].hasPrefix("```") {
            return "```"
        }

        if source[index...].hasPrefix("~~~") {
            return "~~~"
        }

        return nil
    }

    private func endOfFence(
        _ marker: String,
        in source: String,
        from start: String.Index
    ) -> String.Index {
        var index = lineEnd(in: source, from: start)

        while index < source.endIndex {
            if source[index].isNewline {
                source.formIndex(after: &index)
            }

            if source[index...].hasPrefix(marker) {
                return lineEnd(in: source, from: index)
            }

            index = lineEnd(in: source, from: index)
        }

        return source.endIndex
    }

    private func endOfDelimited(
        _ delimiter: String,
        in source: String,
        from start: String.Index
    ) -> String.Index? {
        let contentStart = source.index(start, offsetBy: delimiter.count)

        guard contentStart < source.endIndex,
              let closingRange = source.range(
                of: delimiter,
                range: contentStart..<source.endIndex
              ) else {
            return nil
        }

        return closingRange.upperBound
    }

    private func lineEnd(in source: String, from start: String.Index) -> String.Index {
        var index = start

        while index < source.endIndex, source[index].isNewline == false {
            source.formIndex(after: &index)
        }

        return index
    }
}
