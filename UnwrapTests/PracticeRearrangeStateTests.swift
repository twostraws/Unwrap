//
//  PracticeRearrangeStateTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("Rearrange the Lines")
struct RearrangeLinesLogicTests {
    @Test("Correctness requires the same lines in the same order and ignores surrounding whitespace")
    func answerCorrectnessAndCardinality() {
        let correctLines = makeLines(["let value = 42", "print(value)"])

        var correct = makeState(correctLines: correctLines, lines: correctLines)
        let correctResult = correct.submit()
        #expect(correctResult == .correct)

        let whitespaceLines = [
            RearrangeQuestionState.Line(id: 0, text: "  let value = 42\t"),
            RearrangeQuestionState.Line(id: 1, text: "\tprint(value)  ")
        ]
        var whitespace = makeState(correctLines: correctLines, lines: whitespaceLines)
        let whitespaceResult = whitespace.submit()
        #expect(whitespaceResult == .correct)

        var wrongOrder = makeState(correctLines: correctLines, lines: correctLines.reversed())
        let wrongOrderResult = wrongOrder.submit()
        #expect(wrongOrderResult == .incorrect)

        var missingLine = makeState(correctLines: correctLines, lines: [correctLines[0]])
        let missingLineResult = missingLine.submit()
        #expect(missingLineResult == .incorrect)

        var additionalLine = makeState(
            correctLines: correctLines,
            lines: correctLines + [RearrangeQuestionState.Line(id: 2, text: "print(value)")]
        )
        let additionalLineResult = additionalLine.submit()
        #expect(additionalLineResult == .incorrect)
    }

    @Test("Index-set moves preserve ordering and safely ignore invalid indexes")
    func indexSetMoves() {
        let lines = makeLines(["A", "B", "C", "D"])
        let moved = RearrangeQuestionState.moving(
            lines,
            fromOffsets: IndexSet([0, 2]),
            toOffset: 3
        )
        let unchanged = RearrangeQuestionState.moving(
            lines,
            fromOffsets: IndexSet([20]),
            toOffset: 0
        )

        #expect(moved.map(\.text) == ["B", "A", "C", "D"])
        #expect(Set(moved.map(\.id)) == Set(lines.map(\.id)))
        #expect(unchanged == lines)
    }

    @Test("Submission reports each line and freezes subsequent edits")
    func resultsAndLocking() {
        let lines = makeLines(["A", "B", "C"])
        var state = makeState(correctLines: lines, lines: [lines[1], lines[0], lines[2]])

        #expect(state.result(for: lines[0]) == .unanswered)
        let result = state.submit()
        #expect(result == .incorrect)
        #expect(state.result(for: lines[1]) == .incorrect)
        #expect(state.result(for: lines[0]) == .incorrect)
        #expect(state.result(for: lines[2]) == .correct)

        let lockedLines = state.lines
        state.move(fromOffsets: IndexSet(integer: 0), toOffset: 2)
        #expect(state.lines == lockedLines)
        let repeatedResult = state.submit()
        #expect(repeatedResult == nil)
    }

    @Test("Code is split into lines, tabs become spaces, and the lines start out of order", arguments: 0..<50)
    func generatedPresentation(seed: Int) {
        var state = RearrangeQuestionState(
            prompt: "Put the lines in order.",
            hint: "",
            code: "func greet() {\n\tlet name = \"Swift\"\n\tprint(name)\n}",
            random: SeededRandomSource(seed: UInt64(seed))
        )

        #expect(
            state.correctLines.map(\.text)
                == ["func greet() {", "   let name = \"Swift\"", "   print(name)", "}"]
        )
        #expect(state.correctLines.map(\.id) == [0, 1, 2, 3])
        #expect(state.lines.map(\.id).sorted() == [0, 1, 2, 3])
        #expect(state.lines != state.correctLines, "Seed \(seed) presented the lines already in order.")
        #expect(state.isLocked == false)
        #expect(state.submit() == .incorrect, "Seed \(seed) presented an accepted answer.")
    }

    @Test("A shuffle that changes nothing is nudged out of order")
    func identityShuffleIsRejected() {
        // Choosing each line's own index leaves a Fisher-Yates shuffle exactly where it started.
        let state = RearrangeQuestionState(
            prompt: "",
            hint: "",
            code: "first\nsecond\nthird",
            random: ScriptedRandomSource([2, 1])
        )

        #expect(state.lines.map(\.text) == ["second", "third", "first"])
    }

    @Test("The fallback changes the answer even when its first two lines are equivalent")
    func fallbackWithRepeatedLeadingLines() {
        var state = RearrangeQuestionState(
            prompt: "",
            hint: "",
            code: "}\n  }\nprint(value)",
            random: ScriptedRandomSource([2, 1])
        )

        #expect(state.lines.sorted { $0.id < $1.id } == state.correctLines)
        #expect(state.submit() == .incorrect)
    }

    @Test("A single line has nothing to rearrange")
    func singleLine() {
        var state = RearrangeQuestionState(
            prompt: "",
            hint: "",
            code: "print(\"Hello\")",
            random: SeededRandomSource(seed: 1)
        )

        #expect(state.lines == state.correctLines)
        #expect(state.submit() == .correct)
    }

    @Test("Moving lines into the right order solves a generated question")
    func solvingByMoving() {
        var state = RearrangeQuestionState(
            prompt: "",
            hint: "",
            code: "first\nsecond\nthird",
            random: ScriptedRandomSource([2, 1])
        )

        // Presented as second, third, first: drag the last line to the top.
        state.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)

        #expect(state.lines == state.correctLines)
        #expect(state.submit() == .correct)
        #expect(state.correctLines.allSatisfy { state.result(for: $0) == .correct })
    }

    /// Closing braces with different indentation have the same content for answer validation.
    @Test("A shuffle that only swaps identical lines isn't presented as a question")
    func identicalLinesSwapped() {
        // The scripted choices swap the final two lines and leave everything else in place.
        var state = RearrangeQuestionState(
            prompt: "",
            hint: "",
            code: "func greet() {\n\tif isReady {\n\t\tprint(\"Hi\")\n\t}\n}",
            random: ScriptedRandomSource([3, 3, 2, 1])
        )

        #expect(state.lines.sorted { $0.id < $1.id } == state.correctLines)
        #expect(state.submit() == .incorrect, "The question arrived already solved.")
    }

    @Test("Repeated lines never produce a solved question when distinct content exists", arguments: 0..<50)
    func repeatedLines(seed: Int) {
        var state = RearrangeQuestionState(
            prompt: "",
            hint: "",
            code: "first\n  }\n}\n\t}\nfirst\n}",
            random: SeededRandomSource(seed: UInt64(seed))
        )

        #expect(state.lines.sorted { $0.id < $1.id } == state.correctLines)
        #expect(state.submit() == .incorrect, "Seed \(seed) presented an accepted answer.")
    }

    @Test("Content without a distinct ordering remains intact", arguments: ["", "}\n  }\n\t}", "\n \n\t"])
    func equivalentLines(code: String) {
        var state = RearrangeQuestionState(
            prompt: "",
            hint: "",
            code: code,
            random: SeededRandomSource(seed: 1)
        )

        #expect(state.lines == state.correctLines)
        #expect(state.submit() == .correct)
    }

    private func makeLines(_ text: [String]) -> [RearrangeQuestionState.Line] {
        text.enumerated().map { RearrangeQuestionState.Line(id: $0.offset, text: $0.element) }
    }

    private func makeState(
        correctLines: [RearrangeQuestionState.Line],
        lines: some Sequence<RearrangeQuestionState.Line>
    ) -> RearrangeQuestionState {
        RearrangeQuestionState(
            prompt: "Put the lines in order.",
            hint: "Create the value before using it.",
            correctLines: correctLines,
            lines: Array(lines)
        )
    }
}
