//
//  RearrangeQuestionState.swift
//  Unwrap
//

import Foundation

struct RearrangeQuestionState: Equatable {
    struct Line: Identifiable, Equatable {
        let id: Int
        let text: String
    }

    enum LineResult: Equatable {
        case unanswered
        case correct
        case incorrect
    }

    let prompt: String
    let hint: String
    let correctLines: [Line]

    private(set) var lines: [Line]
    private(set) var outcome: PracticeAnswerResult?

    var isLocked: Bool {
        outcome != nil
    }

    init(prompt: String, hint: String, code: String, random: any RandomProviding) {
        self.prompt = prompt
        self.hint = hint
        let spacedCode = code.replacing("\t", with: "   ")
        correctLines = spacedCode.components(separatedBy: "\n").enumerated().map {
            Line(id: $0.offset, text: $0.element)
        }
        lines = Self.unsolvedShuffle(correctLines, random: random)
    }

    init(prompt: String, hint: String, correctLines: [Line], lines: [Line]) {
        self.prompt = prompt
        self.hint = hint
        self.correctLines = correctLines
        self.lines = lines
    }

    mutating func move(fromOffsets: IndexSet, toOffset: Int) {
        guard isLocked == false else { return }
        lines = Self.moving(lines, fromOffsets: fromOffsets, toOffset: toOffset)
    }

    @discardableResult
    mutating func submit() -> PracticeAnswerResult? {
        guard outcome == nil else { return nil }
        let result: PracticeAnswerResult = isCorrect ? .correct : .incorrect
        outcome = result
        return result
    }

    func result(for line: Line) -> LineResult {
        guard outcome != nil,
              let index = lines.firstIndex(where: { $0.id == line.id }),
              correctLines.indices.contains(index) else {
            return .unanswered
        }

        return Self.normalized(lines[index].text) == Self.normalized(correctLines[index].text)
            ? .correct
            : .incorrect
    }

    static func moving(_ input: [Line], fromOffsets: IndexSet, toOffset: Int) -> [Line] {
        var result = input
        let movingLines = fromOffsets.compactMap { input.indices.contains($0) ? input[$0] : nil }
        guard movingLines.isEmpty == false else { return input }

        for index in fromOffsets.sorted(by: >) where result.indices.contains(index) {
            result.remove(at: index)
        }

        let removedBeforeDestination = fromOffsets.count(where: { $0 < toOffset })
        let insertionIndex = min(max(toOffset - removedBeforeDestination, 0), result.count)
        result.insert(contentsOf: movingLines, at: insertionIndex)
        return result
    }

    private var isCorrect: Bool {
        Self.hasMatchingContent(lines, correctLines)
    }

    private static func hasMatchingContent(_ first: [Line], _ second: [Line]) -> Bool {
        guard first.count == second.count else { return false }
        return zip(first, second).allSatisfy {
            Self.normalized($0.text) == Self.normalized($1.text)
        }
    }

    private static func unsolvedShuffle(_ input: [Line], random: any RandomProviding) -> [Line] {
        guard input.count > 1 else { return input }

        let shuffled = random.shuffled(input)
        if hasMatchingContent(shuffled, input) == false {
            return shuffled
        }

        // A one-position rotation changes the answer unless every normalized line is identical.
        // Those questions have no incorrect ordering, so keep their original presentation.
        let rotated = Array(input.dropFirst()) + [input[0]]
        return hasMatchingContent(rotated, input) ? input : rotated
    }

    private static func normalized(_ input: String) -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
