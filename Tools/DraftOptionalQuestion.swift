// Run with the Xcode 27 toolchain on an Apple Intelligence-capable Mac.
import Foundation
import FoundationModels

@available(macOS 26, *)
@Generable
enum OptionalExample {
    case missing, empty, present
}

@available(macOS 26, *)
@Generable
struct QuestionIdea {
    @Guide(description: "An ordinary English first name, letters only.")
    var name: String
    @Guide(description: "A short fallback label for an unnamed visitor, letters only.")
    var fallback: String
    var example: OptionalExample
}

enum DraftError: LocalizedError {
    case unavailable, unusableLabels

    var errorDescription: String? {
        switch self {
        case .unavailable: "Enable Apple Intelligence and download the on-device model for a supported language."
        case .unusableLabels: "The generated labels were unsuitable. Run again to draft a different example."
        }
    }
}

struct DraftQuestion: Encodable {
    struct Answer: Encodable { let text: String }
    let code: String
    let answers: [Answer]
}

@available(macOS 26, *)
func draft() async throws -> DraftQuestion {
    let model = SystemLanguageModel.default
    guard model.isAvailable, model.supportsLocale() else { throw DraftError.unavailable }
    let session = LanguageModelSession(model: model)
    let idea = try await session.respond(
        to: "Design a Predict the Output example about the difference between a missing nickname, an empty nickname and a nonempty nickname.",
        generating: QuestionIdea.self
    ).content
    guard [idea.name, idea.fallback].allSatisfy({ (1...20).contains($0.count) && $0.allSatisfy(\.isLetter) }),
          idea.name.lowercased() != idea.fallback.lowercased() else { throw DraftError.unusableLabels }

    let nickname: String?
    switch idea.example {
    case .missing: nickname = nil
    case .empty: nickname = ""
    case .present: nickname = idea.name
    }
    let literal = nickname.map { String(reflecting: $0) } ?? "nil"
    let code = """
    let nickname: String? = \(literal)
    let label = nickname ?? \(String(reflecting: idea.fallback))
    print("Badge: [\\(label)]")
    """
    return DraftQuestion(code: code, answers: [.init(text: "Badge: [\(nickname ?? idea.fallback)]")])
}

do {
    guard #available(macOS 26, *) else { throw DraftError.unavailable }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try await encoder.encode(draft())
    FileHandle.standardOutput.write(data)
    print()
} catch {
    FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
    exit(1)
}
