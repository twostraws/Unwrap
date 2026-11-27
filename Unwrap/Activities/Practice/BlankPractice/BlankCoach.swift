import FoundationModels

@Generable
enum HintStrategy {
    case traceInput
    case compareAttempt
    case reasonAboutResult

    func render(question: BlankQuestion, attempted: String) -> String {
        switch self {
        case .traceInput:
            switch question.topic {
            case .arithmetic: "Start with \(question.recipe.left) and \(question.recipe.right). \(question.clue)"
            case .collections: "Point to array positions 0 and 1. Which position holds \(question.output), or is the target the length?"
            case .optionals: "The optional starts with nil. Does the target describe a comparison or a replacement value?"
            }
        case .compareAttempt:
            if question.tokens.contains(attempted.trimmingCharacters(in: .whitespacesAndNewlines)) {
                question.feedback(for: attempted)
            } else {
                question.clue
            }
        case .reasonAboutResult:
            switch question.topic {
            case .arithmetic: "Compare the target \(question.output) with the starting count \(question.recipe.left). \(question.clue)"
            case .collections: "Count the elements, then read the first and last values. Which matches \(question.output)?"
            case .optionals: "Look at \(question.output). Does the missing operation need to return a Bool or an Int?"
            }
        }
    }
}

struct BlankCoach {
    private let model = SystemLanguageModel.default

    var available: Bool {
        model.isAvailable && model.supportsLocale()
    }

    func question(topic: BlankTopic, after previous: BlankOperation) async throws -> BlankQuestion? {
        let session = LanguageModelSession(model: model, instructions: """
        Design the ingredients of one beginner Swift puzzle. Pick a concrete plural noun
        for things to count, two small numbers, and a different operation from the previous one.
        """)
        let prompt = "Topic: \(topic.title). Prior operation: \(previous.rawValue). Create a fresh puzzle."
        let response = try await session.respond(to: prompt, generating: BlankRecipe.self)
        var recipe = response.content
        if recipe.operation == previous {
            recipe.operation = BlankQuestion.authored(topic: topic, after: previous).recipe.operation
        }
        return BlankQuestion(recipe, topic: topic)
    }

    func hint(for question: BlankQuestion, attempted: String, prior: HintStrategy? = nil) async throws -> HintStrategy {
        let session = LanguageModelSession(model: model, instructions: """
        Pick the next coaching move for this Swift learner. With no attempt, tracing the inputs
        helps. After a wrong token, compare its behavior with the goal. After an earlier hint,
        approach the idea a different way. Keep the learner in control of the solution.
        """)
        let token = attempted.trimmingCharacters(in: .whitespacesAndNewlines)
        let knownAttempt = question.tokens.contains(token) ? token : "No recognized token"
        let prompt = """
        Code: \(question.code)
        Output goal: \(question.output)
        Attempt: \(knownAttempt)
        Previous help: \(prior.map(String.init(describing:)) ?? "none")
        """
        let result = try await session.respond(to: prompt, generating: HintStrategy.self).content
        if result == prior { return result == .reasonAboutResult ? .traceInput : .reasonAboutResult }
        return result
    }
}
