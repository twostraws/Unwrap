//
//  SpotErrorQuestionState.swift
//  Unwrap
//

import Foundation

struct SpotErrorQuestionState: Equatable {
    private struct GeneratedError {
        let code: String
        let kind: ErrorKind
        let lineNumber: Int
    }

    struct Line: Identifiable, Equatable {
        let id: Int
        let text: String
    }

    enum ErrorKind: CaseIterable, Equatable {
        case badResultType
        case badReturnType
        case badValue
        case badWhitespace
        case missingBrace
        case missingMinus
        case missingParenthesis
        case missingQuote
        case missingReturnType
        case missingReturnValue
        case typoCaseCall
        case typoCaseReturn
        case typoColon
        case typoFunction
        case typoQuotes
        case typoReturn
        case anonymousParameters
        case removingVar
    }

    enum LineResult: Equatable {
        case unanswered
        case selected
        case correct
        case incorrect
    }

    let prompt = "Which line of code contains an error?"
    let hint = "If there is an error, it will only be on one line. If you see one line contradict another, the earlier line will always be correct."
    let lines: [Line]
    let error: ErrorKind
    let errorLineID: Int

    private(set) var selectedLineID: Int?
    private(set) var scrollTargetID: Int?
    private(set) var outcome: PracticeAnswerResult?

    var isReadyToSubmit: Bool {
        selectedLineID != nil
    }

    var isLocked: Bool {
        outcome != nil
    }

    init(
        content: SpotErrorContent,
        source: String,
        random: any RandomProviding
    ) throws {
        let generated = try Self.generateError(in: source, random: random)
        let replacedCode = try Self.applyReplacements(
            to: generated.code,
            using: content,
            random: random
        )
        let generatedLines = replacedCode.components(separatedBy: "\n")

        guard generatedLines.indices.contains(generated.lineNumber) else {
            throw PracticeContentError.invalidContent("SpotTheError-\(content.file).txt")
        }

        lines = generatedLines.enumerated().map { Line(id: $0.offset, text: $0.element) }
        error = generated.kind
        errorLineID = generated.lineNumber
    }

    init(lines: [Line], error: ErrorKind, errorLineID: Int) {
        self.lines = lines
        self.error = error
        self.errorLineID = errorLineID
    }

    mutating func select(lineID: Int) {
        guard lines.contains(where: { $0.id == lineID }), isLocked == false else { return }
        selectedLineID = selectedLineID == lineID ? nil : lineID
    }

    @discardableResult
    mutating func submit() -> PracticeAnswerResult? {
        guard let selectedLineID, outcome == nil else { return nil }
        let result: PracticeAnswerResult = selectedLineID == errorLineID ? .correct : .incorrect
        outcome = result
        scrollTargetID = errorLineID
        return result
    }

    func result(for line: Line) -> LineResult {
        guard outcome != nil else {
            return selectedLineID == line.id ? .selected : .unanswered
        }

        if line.id == selectedLineID {
            return line.id == errorLineID ? .correct : .incorrect
        }

        // If the user picked another line, the real error is also shown as
        // wrong so both parts of the mistake are visible, matching UIKit.
        return line.id == errorLineID ? .incorrect : .unanswered
    }

    private static func generateError(
        in code: String,
        random: any RandomProviding
    ) throws -> GeneratedError {
        let kinds = ErrorKind.allCases
        let startIndex = random.nextInt(in: 0...(kinds.count - 1))

        for offset in kinds.indices {
            let kind = kinds[(startIndex + offset) % kinds.count]
            let mutation = try mutate(code, with: kind, random: random)

            guard mutation.code != code else { continue }

            let lineNumber = mutation.lineNumber ?? firstDifferentLine(in: mutation.code, from: code)
            guard lineNumber >= 0 else { continue }
            return GeneratedError(code: mutation.code, kind: kind, lineNumber: lineNumber)
        }

        throw PracticeContentError.invalidContent("Spot the Error source")
    }

    private static func mutate(
        _ code: String,
        with error: ErrorKind,
        random: any RandomProviding
    ) throws -> (code: String, lineNumber: Int?) {
        let lines = code.components(separatedBy: "\n")
        let lastLine = lines.count - 1

        switch error {
        case .badResultType:
            return (code.replacing("RETURN_NAME: String", with: "RETURN_NAME: Int"), nil)

        case .badReturnType:
            let replacements = ["Double", "Float", "Int"]
            let replacement = random.element(from: replacements) ?? "Int"
            return (
                code.replacing("-> String", with: "-> \(replacement)"),
                lines.firstIndex(of: "    return RETURN_NAME")
            )

        case .badValue:
            let replacement: String
            switch random.nextInt(in: 0...2) {
            case 0:
                replacement = "INPUT_VALUE.\(random.nextInt(in: 0...9))"
            case 1:
                replacement = "\"INPUT_VALUE\""
            default:
                replacement = "[INPUT_VALUE]"
            }
            return (code.replacing("INPUT_VALUE", with: replacement), lastLine)

        case .badWhitespace:
            return (try replacingOne(in: code, pattern: "( \\+= )", with: " +=", random: random), nil)

        case .missingBrace:
            return (try replacingOne(in: code, pattern: "(\\{)", with: "", random: random), nil)

        case .missingMinus:
            return (code.replacing("->", with: ">"), 0)

        case .missingParenthesis:
            if code.contains(")\n") {
                return (try replacingOne(in: code, pattern: "(\\)\\n)", with: "\n", random: random), nil)
            } else if code.contains("))") {
                return (try replacingOne(in: code, pattern: "(\\)\\))", with: ")", random: random), nil)
            } else if code.contains(") ") {
                return (try replacingOne(in: code, pattern: "(\\) )", with: " ", random: random), nil)
            } else {
                return (code, nil)
            }

        case .missingQuote:
            return (try replacingOne(in: code, pattern: "(\")", with: "", random: random), nil)

        case .missingReturnType:
            return (
                code.replacing(" -> String", with: ""),
                lines.firstIndex(of: "    return RETURN_NAME")
            )

        case .missingReturnValue:
            return (code.replacing("return RETURN_NAME", with: "return"), nil)

        case .typoCaseCall:
            return (code.replacing("print(FUNCTION_NAME", with: "print(function_name"), lastLine)

        case .typoCaseReturn:
            return (try replacingOne(in: code, pattern: "(-> String)", with: "-> string", random: random), 0)

        case .typoColon:
            return (try replacingOne(in: code, pattern: "(:)", with: ";", random: random), nil)

        case .typoFunction:
            return (try replacingOne(in: code, pattern: "(func )", with: "function ", random: random), 0)

        case .typoQuotes:
            return (try replacingOne(in: code, pattern: "(\")", with: "'", random: random), nil)

        case .typoReturn:
            return (code.replacing("return", with: "retrun"), nil)

        case .anonymousParameters:
            return (code.replacing("PARAM_NAME: Int", with: "_ PARAM_NAME: Int"), lastLine)

        case .removingVar:
            return (try replacingOne(in: code, pattern: "(var )", with: "", random: random), nil)
        }
    }

    private static func replacingOne(
        in input: String,
        pattern: String,
        with replacement: String,
        random: any RandomProviding
    ) throws -> String {
        let expression = try NSRegularExpression(pattern: pattern)
        let matches = expression.matches(
            in: input,
            range: NSRange(input.startIndex..., in: input)
        )

        guard let match = random.element(from: matches),
              let range = Range(match.range(at: 1), in: input) else {
            return input
        }

        var output = input
        output.replaceSubrange(range, with: replacement)
        return output
    }

    private static func applyReplacements(
        to code: String,
        using content: SpotErrorContent,
        random: any RandomProviding
    ) throws -> String {
        var output = code

        for replacement in content.replacements {
            guard let value = random.element(from: replacement.values) else {
                throw PracticeContentError.invalidContent("SpotTheError-\(content.file).txt")
            }

            output = output.replacing(replacement.name, with: value)
            output = output.replacing(replacement.name.lowercased(), with: value.lowercased())
        }

        let inputValue = random.nextInt(in: content.inputMinimum...content.inputMaximum)
        return output.replacing("INPUT_VALUE", with: String(inputValue))
    }

    private static func firstDifferentLine(in code: String, from original: String) -> Int {
        let codeLines = code.components(separatedBy: "\n")
        let originalLines = original.components(separatedBy: "\n")

        for (index, pair) in zip(codeLines, originalLines).enumerated() where pair.0 != pair.1 {
            return index
        }

        return codeLines.count == originalLines.count ? -1 : min(codeLines.count, originalLines.count)
    }
}
