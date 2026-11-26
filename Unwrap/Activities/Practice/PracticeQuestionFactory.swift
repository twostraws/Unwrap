//
//  PracticeQuestionFactory.swift
//  Unwrap
//

import Foundation

final class PracticeQuestionFactory {
    private let loadData: (String) throws -> Data
    private let user: User
    private let random: any RandomProviding
    private let resolver: PracticePlaceholderResolver
    #if DEBUG
    private var includesUnlearnedReviewSections = false

    static func unlockedForDebug(
        user: User,
        random: any RandomProviding
    ) -> PracticeQuestionFactory {
        let factory = PracticeQuestionFactory(user: user, random: random)
        factory.includesUnlearnedReviewSections = true
        return factory
    }
    #endif

    init(
        user: User,
        random: any RandomProviding,
        loadData: @escaping (String) throws -> Data = { try Bundle.main.data(named: $0) }
    ) {
        self.user = user
        self.random = random
        self.loadData = loadData
        resolver = PracticePlaceholderResolver(random: random)
    }

    func makeQuestion(for kind: PracticeKind) throws -> PracticeQuestion {
        switch kind {
        case .freeCoding:
            return try makeFreeCodingQuestion()
        case .predictTheOutput:
            return try makePredictOutputQuestion()
        case .rearrangeTheLines:
            return try makeRearrangeQuestion()
        case .review:
            return try makeReviewQuestion()
        case .spotTheError:
            return try makeSpotErrorQuestion()
        case .tapToCode:
            return try makeTapToCodeQuestion()
        case .typeChecker:
            return .typeChecker(TypeCheckerQuestionState(random: random))
        }
    }

    private func makeFreeCodingQuestion() throws -> PracticeQuestion {
        let questions = try decode([FreeCodingContent].self, from: "FreeCoding.json")
        let content = try selected(
            from: questions,
            named: "FreeCoding.json"
        )
        return .freeCoding(FreeCodingQuestionState(content: content))
    }

    private func makePredictOutputQuestion() throws -> PracticeQuestion {
        let questions = try decode(
            [PredictOutputContent].self,
            from: "PredictTheOutput.json"
        )
        let content = try selected(
            from: questions,
            named: "PredictTheOutput.json"
        )
        let code = try resolver.resolve(content.code)

        guard let answer = try content.answers.first(where: { answer in
            guard let conditions = answer.conditions else { return true }
            return try conditions.allSatisfy { condition in
                try conditionIsTrue(condition, context: code.context)
            }
        }) else {
            throw PracticeContentError.invalidContent("PredictTheOutput.json")
        }

        let resolvedAnswer = try resolver.resolve(answer.text, context: code.context)
        return .predictOutput(
            PredictOutputQuestionState(code: code.output, correctOutput: resolvedAnswer.output)
        )
    }

    private func makeRearrangeQuestion() throws -> PracticeQuestion {
        let questions = try decode(
            [RearrangeLinesContent].self,
            from: "RearrangeTheLines.json"
        )
        let content = try selected(
            from: questions,
            named: "RearrangeTheLines.json"
        )
        return .rearrange(
            RearrangeQuestionState(
                prompt: content.question,
                hint: content.hint,
                code: content.code,
                random: random
            )
        )
    }

    private func makeReviewQuestion() throws -> PracticeQuestion {
        let sectionIDs = Unwrap.chapters.flatMap(\.sections).map(\.bundleName).filter {
            #if DEBUG
            if includesUnlearnedReviewSections {
                return true
            }
            #endif
            return user.ratingForSection($0) != 0
        }
        let sectionID = try selected(
            from: sectionIDs,
            named: "completed review sections"
        )
        let content = try decode(ReviewContent.self, from: "\(sectionID).json")

        var choices = content.correct.enumerated().map {
            ReviewQuestionState.Choice(
                id: $0.offset,
                text: $0.element.text,
                reason: $0.element.reason,
                isCorrect: true
            )
        }
        choices += content.wrong.enumerated().map {
            ReviewQuestionState.Choice(
                id: content.correct.count + $0.offset,
                text: $0.element.text,
                reason: $0.element.reason,
                isCorrect: false
            )
        }
        choices = random.shuffled(choices)

        guard choices.isEmpty == false else {
            throw PracticeContentError.invalidContent("\(sectionID).json")
        }

        let style: ReviewQuestionState.Style
        switch content.kind {
        case .singleSelection:
            style = .single
            choices = [choices[0]]
        case .multipleSelection:
            style = .multiple
        }

        return .review(
            ReviewQuestionState(
                prompt: content.question,
                hint: content.hint,
                usesSyntaxHighlighting: content.syntaxHighlighting,
                style: style,
                choices: choices
            )
        )
    }

    private func makeSpotErrorQuestion() throws -> PracticeQuestion {
        let questions = try decode([SpotErrorContent].self, from: "SpotTheError.json")
        let content = try selected(
            from: questions,
            named: "SpotTheError.json"
        )
        let source = try text(named: "SpotTheError-\(content.file).txt")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return .spotError(
            try SpotErrorQuestionState(content: content, source: source, random: random)
        )
    }

    private func makeTapToCodeQuestion() throws -> PracticeQuestion {
        let questions = try decode([TapToCodeContent].self, from: "TapToCode.json")
        let content = try selected(
            from: questions,
            named: "TapToCode.json"
        )
        let prompt = try resolver.resolve(content.question)
        let existingCode = try resolver.resolve(content.existingCode, context: prompt.context)
        let components = try content.components.map {
            try resolver.resolve($0, context: existingCode.context).output
        }

        return .tapToCode(
            TapToCodeQuestionState(
                prompt: prompt.output,
                existingCode: existingCode.output,
                components: components,
                random: random
            )
        )
    }

    private func conditionIsTrue(
        _ condition: PredictOutputContent.Condition,
        context: PracticePlaceholderResolver.Context
    ) throws -> Bool {
        let left = resolver.applyingFilter(
            to: try resolver.resolve(condition.left, context: context).output
        )
        let right = resolver.applyingFilter(
            to: try resolver.resolve(condition.right, context: context).output
        )
        let check: String

        if condition.check.hasPrefix("OPERATOR_"),
           let index = Int(condition.check.dropFirst("OPERATOR_".count)),
           context.operators.indices.contains(index) {
            check = context.operators[index]
        } else {
            check = condition.check
        }

        switch check {
        case ">":
            return compare(left, right, integers: >, strings: >)
        case ">=":
            return compare(left, right, integers: >=, strings: >=)
        case "<":
            return compare(left, right, integers: <, strings: <)
        case "<=":
            return compare(left, right, integers: <=, strings: <=)
        case "==":
            return left == right
        case "!=":
            return left != right
        default:
            throw PracticeContentError.invalidContent("PredictTheOutput condition")
        }
    }

    private func compare(
        _ left: String,
        _ right: String,
        integers: (Int, Int) -> Bool,
        strings: (String, String) -> Bool
    ) -> Bool {
        if let leftNumber = Int(left), let rightNumber = Int(right) {
            return integers(leftNumber, rightNumber)
        }

        return strings(left, right)
    }

    private func decode<T: Decodable>(_ type: T.Type, from name: String) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: loadData(name))
    }

    private func text(named name: String) throws -> String {
        let data = try loadData(name)

        guard let result = String(data: data, encoding: .utf8) else {
            throw BundleResourceError.unreadableText(name)
        }

        return result
    }

    private func selected<Element>(
        from elements: [Element],
        named name: String
    ) throws -> Element {
        guard let element = random.element(from: elements) else {
            if name == "completed review sections" {
                throw PracticeContentError.noReviewSections
            }
            throw PracticeContentError.emptyContent(name)
        }

        return element
    }
}
