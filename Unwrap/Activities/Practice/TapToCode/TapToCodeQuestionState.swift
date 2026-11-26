//
//  TapToCodeQuestionState.swift
//  Unwrap
//

import Foundation

struct TapToCodeQuestionState: Equatable {
    let prompt: String
    let hint = "All the code components need to be used somewhere – try rearranging them until you're happy."
    let existingCode: String
    let correctTokens: [TapToCodeToken]

    private(set) var usedTokens = [TapToCodeToken]()
    private(set) var availableTokens: [TapToCodeToken]
    private(set) var outcome: PracticeAnswerResult?

    var isReadyToSubmit: Bool {
        availableTokens.isEmpty
    }

    var isLocked: Bool {
        outcome != nil
    }

    init(
        prompt: String,
        existingCode: String,
        components: [String],
        random: any RandomProviding
    ) {
        self.prompt = prompt
        self.existingCode = existingCode
        correctTokens = components.enumerated().map {
            TapToCodeToken(
                id: $0.offset,
                text: $0.element
            )
        }
        availableTokens = Self.nonidentityShuffle(correctTokens, random: random)
    }

    init(
        prompt: String,
        existingCode: String,
        correctTokens: [TapToCodeToken],
        usedTokens: [TapToCodeToken],
        availableTokens: [TapToCodeToken]
    ) {
        self.prompt = prompt
        self.existingCode = existingCode
        self.correctTokens = correctTokens
        self.usedTokens = usedTokens
        self.availableTokens = availableTokens
    }

    @discardableResult
    mutating func tap(tokenID: Int) -> Bool {
        guard isLocked == false else { return false }

        if let sourceIndex = availableTokens.firstIndex(where: { $0.id == tokenID }) {
            let token = availableTokens.remove(at: sourceIndex)
            usedTokens.append(token)
            return true
        }

        if let sourceIndex = usedTokens.firstIndex(where: { $0.id == tokenID }) {
            let token = usedTokens.remove(at: sourceIndex)
            availableTokens.append(token)
            return true
        }

        return false
    }

    /// Moves tokens in response to a drag, placing them in either area before another token or, with no
    /// target, at the end.
    @discardableResult
    mutating func moveTokens(withIDs ids: [Int], to area: TapToCodeArea, before targetID: Int?) -> Bool {
        guard isLocked == false else { return false }

        let allTokens = usedTokens + availableTokens
        let movingTokens = ids.compactMap { id in allTokens.first { $0.id == id } }
        guard movingTokens.isEmpty == false else { return false }

        var newUsedTokens = usedTokens.filter { ids.contains($0.id) == false }
        var newAvailableTokens = availableTokens.filter { ids.contains($0.id) == false }
        let destination = area == .used ? newUsedTokens : newAvailableTokens
        var insertionIndex = destination.count

        if let targetID {
            guard let targetIndex = destination.firstIndex(where: { $0.id == targetID }) else { return false }
            insertionIndex = targetIndex
        }

        if area == .used {
            newUsedTokens.insert(contentsOf: movingTokens, at: insertionIndex)
        } else {
            newAvailableTokens.insert(contentsOf: movingTokens, at: insertionIndex)
        }

        usedTokens = newUsedTokens
        availableTokens = newAvailableTokens
        return true
    }

    @discardableResult
    mutating func submit() -> PracticeAnswerResult? {
        guard isReadyToSubmit, outcome == nil else { return nil }
        let result: PracticeAnswerResult = usedTokens.map(\.text) == correctTokens.map(\.text)
            ? .correct
            : .incorrect
        outcome = result
        return result
    }

    private static func nonidentityShuffle(
        _ input: [TapToCodeToken],
        random: any RandomProviding
    ) -> [TapToCodeToken] {
        guard input.count > 1 else { return input }
        let shuffled = random.shuffled(input)

        if shuffled.map(\.id) != input.map(\.id) {
            return shuffled
        }

        return Array(input.dropFirst()) + [input[0]]
    }
}
