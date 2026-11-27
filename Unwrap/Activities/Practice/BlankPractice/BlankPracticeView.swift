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
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                topicPicker
                GroupBox(source) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Counting \(question.recipe.objects). Fill the blank to print \(question.output).")
                            .font(.headline)
                        Text(question.code).font(.body.monospaced())
                        Text("Choose from " + question.tokens.joined(separator: ", ") + ".")
                        TextField("Token", text: $answer)
                            .accessibilityLabel("Missing Swift token")
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled().textInputAutocapitalization(.never)
                            .disabled(solved || request != nil)
                            .onSubmit(check)
                        Button("Check answer", action: check)
                            .disabled(answer.isEmpty || solved || request != nil)
                        if !feedback.isEmpty { Text(feedback) }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if !solved {
                    Button("Get a hint") { request = .hint(UUID(), answer) }
                        .disabled(request != nil)
                }
                Button(coach.available ? "Generate a question" : "Next question") { request = .question(UUID()) }
                    .disabled(request != nil)
                if request != nil { ProgressView("Preparing practice") }
                Text(coach.available ? "New questions and hints use Apple Intelligence on this device." : "Apple Intelligence is unavailable. Built-in questions and hints are ready.")
                    .font(.footnote)
            }
            .font(.body)
            .buttonStyle(.bordered)
            .frame(maxWidth: 600, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Fill in the Blank")
        .safeAreaInset(edge: .bottom) {
            Button("Done") { dismiss() }
                .font(.body)
                .buttonStyle(.borderedProminent)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
        }
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

    private var topicPicker: some View {
        Picker("Topic", selection: Binding(get: { question.topic }, set: { topic in
            request = nil
            question = .authored(topic: topic)
            resetAnswer(generated: false)
        })) {
            ForEach(BlankTopic.allCases, id: \.self) { Text($0.title).tag($0) }
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
