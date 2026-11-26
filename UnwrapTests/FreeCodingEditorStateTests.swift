//
//  FreeCodingEditorStateTests.swift
//  UnwrapTests
//

import SwiftUI
import Testing
@testable import Unwrap

@Suite("Free Coding editor")
struct FreeCodingEditorStateTests {
    @Test("Symbols inserted in the middle of Free Coding leave the cursor where the learner is typing")
    func editorKeepsCursorPosition() {
        var editor = FreeCodingEditorState(source: "print name)", colorScheme: .light)
        let text = editor.attributedText
        editor.selection = AttributedTextSelection(
            insertionPoint: text.index(text.startIndex, offsetByCharacters: 5)
        )

        editor.insert("(", colorScheme: .light)
        editor.insert("\"", colorScheme: .light)
        #expect(editor.source == "print(\" name)")

        guard case .insertionPoint(let cursor) = editor.selection.indices(in: editor.attributedText) else {
            Issue.record("Expected a single insertion point.")
            return
        }

        let edited = editor.attributedText
        #expect(edited.characters.distance(from: edited.startIndex, to: cursor) == 7)
    }
}
