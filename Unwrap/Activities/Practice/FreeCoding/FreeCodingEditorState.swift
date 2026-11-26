//
//  FreeCodingEditorState.swift
//  Unwrap
//

import SwiftUI

struct FreeCodingEditorState: Equatable {
    private(set) var attributedText: AttributedString
    var selection: AttributedTextSelection

    var source: String {
        String(attributedText.characters)
    }

    init(source: String, colorScheme: ColorScheme) {
        let highlighted = SwiftCodeHighlighter().attributedString(for: source, colorScheme: colorScheme)
        attributedText = highlighted
        selection = AttributedTextSelection(insertionPoint: highlighted.endIndex)
    }

    mutating func receiveEditedText(_ editedText: AttributedString, colorScheme: ColorScheme) {
        attributedText = editedText
        rehighlight(colorScheme: colorScheme)
    }

    mutating func rehighlight(colorScheme: ColorScheme) {
        let highlighted = SwiftCodeHighlighter().attributedString(for: source, colorScheme: colorScheme)
        guard highlighted != attributedText else { return }

        // Restyle the existing text one run at a time rather than swapping in the highlighted copy: replacing
        // the whole string loses track of the selection, which sends the cursor to the end of the code.
        attributedText.transform(updating: &selection) { text in
            var lowerBound = text.startIndex

            for run in highlighted.runs {
                let length = highlighted.unicodeScalars.distance(from: run.range.lowerBound, to: run.range.upperBound)
                let upperBound = text.index(lowerBound, offsetByUnicodeScalars: length)
                text[lowerBound..<upperBound].setAttributes(run.attributes)
                lowerBound = upperBound
            }
        }
    }

    mutating func insert(_ symbol: Character, colorScheme: ColorScheme) {
        attributedText.replaceSelection(&selection, withCharacters: [symbol])
        rehighlight(colorScheme: colorScheme)
    }
}
