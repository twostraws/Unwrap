import SwiftUI

struct BlankPracticeView: View {
    private enum Request: Equatable {
        case question(UUID)
        case hint(UUID, String)
    }

    @Environment(\.dismiss) private var dismiss
    @State private var question = BlankQuestion.authored(topic: .arithmetic)
    @State private var answer = ""
    @State private var feedback = ""
    @State private var priorHint: HintStrategy?
    @State private var solved = false
    @State private var request: Request?
    @State private var source = "Practice example"
    private let coach = BlankCoach()

    var body: some View {
        Form {
            Picker("Topic", selection: Binding(get: { question.topic }, set: { topic in
                request = nil
                question = .authored(topic: topic)
                resetAnswer(generated: false)
            })) {
                ForEach(BlankTopic.allCases, id: \.self) { Text($0.title).tag($0) }
            }
            Section(source) {
                Text("Counting \(question.recipe.objects). Fill the blank to print \(question.output).")
                    .font(.headline)
                Text(question.code).font(.body.monospaced())
                Text("Choose from " + question.tokens.joined(separator: ", ") + ".")
                TextField("Missing Swift token", text: $answer)
                    .autocorrectionDisabled().textInputAutocapitalization(.never)
                    .disabled(solved || request != nil)
                    .onSubmit(check)
                Button("Check answer", action: check).disabled(answer.isEmpty || solved || request != nil)
                if !feedback.isEmpty { Text(feedback) }
            }
            Section {
                if !solved {
                    Button("Get a hint") { request = .hint(UUID(), answer) }
                }
                Button(coach.available ? "Generate a question" : "Next question") { request = .question(UUID()) }
            }
            .disabled(request != nil)
            if request != nil { ProgressView("Preparing practice") }
            Text(coach.available ? "New questions and hints use Apple Intelligence on this device." : "Apple Intelligence is unavailable. Built-in questions and hints are ready.")
                .font(.footnote)
        }
        .navigationTitle("Fill in the Blank")
        .toolbar { Button("Done") { dismiss() } }
        .task(id: request) {
            guard let current = request else { return }
            switch current {
            case .question:
                let generated = coach.available ? try? await coach.question(topic: question.topic, after: question.recipe.operation) : nil
                guard !Task.isCancelled, current == request else { return }
                question = generated ?? .authored(topic: question.topic, after: question.recipe.operation)
                resetAnswer(generated: generated != nil)
            case .hint(_, let attempted):
                let hint = coach.available ? try? await coach.hint(for: question, attempted: attempted, prior: priorHint) : nil
                guard !Task.isCancelled, current == request else { return }
                let strategy = hint ?? (priorHint == nil ? HintStrategy.traceInput : .reasonAboutResult)
                feedback = strategy.render(question: question, attempted: attempted)
                priorHint = strategy
            }
            request = nil
        }
    }

    private func resetAnswer(generated: Bool) {
        source = generated ? "Generated with Apple Intelligence" : "Practice example"
        priorHint = nil
        answer = ""
        feedback = ""
        solved = false
    }

    private func check() {
        guard !solved, request == nil, !answer.isEmpty else { return }
        solved = question.accepts(answer)
        feedback = solved ? "Correct! The result is \(question.output)." : question.feedback(for: answer)
        priorHint = nil
    }
}
