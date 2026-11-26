//
//  PracticeTapToCodeStateTests.swift
//  UnwrapTests
//

import Testing
@testable import Unwrap

@Suite("Tap to Code")
struct TapToCodeStateTests {
    @Test("Tapping tokens between zones preserves the exact multiset")
    func tappingPreservesContent() {
        var state = makeState()
        let expectedTokens = Set(state.correctTokens)
        let firstToken = state.availableTokens[0]

        let firstMove = state.tap(tokenID: firstToken.id)
        #expect(firstMove)
        #expect(state.usedTokens == [firstToken])
        #expect(state.availableTokens.count == 2)
        #expect(Set(state.usedTokens + state.availableTokens) == expectedTokens)

        let secondMove = state.tap(tokenID: firstToken.id)
        #expect(secondMove)
        #expect(state.usedTokens.isEmpty)
        #expect(state.availableTokens.count == 3)
        let invalidMove = state.tap(tokenID: 999)
        #expect(invalidMove == false)
    }

    @Test("Dragging moves tokens within and between the two areas, ignoring unknown tokens and targets")
    func reordering() {
        let tokens = makeTokens()
        var state = makeState(
            correctTokens: tokens,
            usedTokens: [tokens[0], tokens[1]],
            availableTokens: [tokens[2]]
        )

        let movedToFront = state.moveTokens(withIDs: [tokens[1].id], to: .used, before: tokens[0].id)
        #expect(movedToFront)
        #expect(state.usedTokens == [tokens[1], tokens[0]])

        let movedToEnd = state.moveTokens(withIDs: [tokens[1].id], to: .used, before: nil)
        #expect(movedToEnd)
        #expect(state.usedTokens == [tokens[0], tokens[1]])
        #expect(state.availableTokens == [tokens[2]])

        let draggedIn = state.moveTokens(withIDs: [tokens[2].id], to: .used, before: tokens[1].id)
        #expect(draggedIn)
        #expect(state.usedTokens == [tokens[0], tokens[2], tokens[1]])
        #expect(state.availableTokens.isEmpty)

        let draggedOut = state.moveTokens(withIDs: [tokens[0].id], to: .available, before: nil)
        #expect(draggedOut)
        #expect(state.usedTokens == [tokens[2], tokens[1]])
        #expect(state.availableTokens == [tokens[0]])

        let snapshot = state
        let unknownMove = state.moveTokens(withIDs: [999], to: .used, before: nil)
        let unknownTarget = state.moveTokens(withIDs: [tokens[2].id], to: .used, before: 999)
        let targetInOtherArea = state.moveTokens(withIDs: [tokens[2].id], to: .used, before: tokens[0].id)
        let ontoItself = state.moveTokens(withIDs: [tokens[2].id], to: .used, before: tokens[2].id)
        #expect(unknownMove == false)
        #expect(unknownTarget == false)
        #expect(targetInOtherArea == false)
        #expect(ontoItself == false)
        #expect(state == snapshot)
    }

    @Test("Only a complete canonical order is accepted")
    func exactOrderAndLocking() {
        let tokens = makeTokens()
        var incomplete = makeState(
            correctTokens: tokens,
            usedTokens: [tokens[0], tokens[1]],
            availableTokens: [tokens[2]]
        )
        #expect(incomplete.isReadyToSubmit == false)
        let incompleteResult = incomplete.submit()
        #expect(incompleteResult == nil)

        var wrong = makeState(
            correctTokens: tokens,
            usedTokens: [tokens[2], tokens[1], tokens[0]],
            availableTokens: []
        )
        let wrongResult = wrong.submit()
        #expect(wrongResult == .incorrect)
        #expect(wrong.isLocked)

        let lockedState = wrong
        let lockedTap = wrong.tap(tokenID: tokens[0].id)
        let lockedMove = wrong.moveTokens(withIDs: [tokens[0].id], to: .available, before: nil)
        #expect(lockedTap == false)
        #expect(lockedMove == false)
        #expect(wrong == lockedState)
        let repeatedResult = wrong.submit()
        #expect(repeatedResult == nil)

        var correct = makeState(
            correctTokens: tokens,
            usedTokens: tokens,
            availableTokens: []
        )
        let correctResult = correct.submit()
        #expect(correctResult == .correct)
    }

    @Test("Duplicate token text remains distinguishable by stable identity")
    func duplicateTextIdentity() {
        let state = TapToCodeQuestionState(
            prompt: "Build it.",
            existingCode: "",
            components: ["value", "value", "value"],
            random: SeededRandomSource(seed: 1)
        )

        #expect(Set(state.correctTokens.map(\.id)).count == 3)
        #expect(Set(state.correctTokens.map(\.text)) == ["value"])
    }

    @Test("Swapping visually identical duplicate tokens is still correct")
    func swappedDuplicateSubmission() {
        let correctTokens = ["{", "value", "}", "}"].enumerated().map {
            TapToCodeToken(
                id: $0.offset,
                text: $0.element
            )
        }
        var state = makeState(
            correctTokens: correctTokens,
            usedTokens: [correctTokens[0], correctTokens[1], correctTokens[3], correctTokens[2]],
            availableTokens: []
        )

        #expect(state.usedTokens.map(\.id) != state.correctTokens.map(\.id))
        #expect(state.usedTokens.map(\.text) == state.correctTokens.map(\.text))
        #expect(state.submit() == .correct)
    }

    private func makeState() -> TapToCodeQuestionState {
        TapToCodeQuestionState(
            prompt: "Build the code.",
            existingCode: "",
            components: ["alpha", "beta", "gamma"],
            random: SeededRandomSource(seed: 5)
        )
    }

    private func makeTokens() -> [TapToCodeToken] {
        ["alpha", "beta", "gamma"].enumerated().map {
            TapToCodeToken(
                id: $0.offset,
                text: $0.element
            )
        }
    }

    private func makeState(
        correctTokens: [TapToCodeToken],
        usedTokens: [TapToCodeToken],
        availableTokens: [TapToCodeToken]
    ) -> TapToCodeQuestionState {
        TapToCodeQuestionState(
            prompt: "Build the code.",
            existingCode: "",
            correctTokens: correctTokens,
            usedTokens: usedTokens,
            availableTokens: availableTokens
        )
    }
}
