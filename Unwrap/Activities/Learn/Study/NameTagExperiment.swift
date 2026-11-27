import SwiftUI

enum BadgeInput: String, CaseIterable {
    case missing = "nil"
    case name = #""Fern""#
    case blank = #""""#

    var nickname: String? {
        switch self {
        case .missing: nil
        case .name: "Fern"
        case .blank: ""
        }
    }

    func displayedName(fallback: String) -> String {
        nickname ?? fallback
    }
}

struct NameTagExperiment: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var input = BadgeInput.missing
    @State private var fallback = "Guest"
    @FocusState private var editingFallback: Bool
    @State private var savedFallback = "Guest"
    @State private var prediction: String?
    @State private var playlistAnswer: Bool?

    private var display: String {
        let result = input.displayedName(fallback: fallback)
        return result.isEmpty ? "(blank)" : result
    }

    var body: some View {
        GroupBox("The missing name tag") {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Nickname", selection: $input) {
                    ForEach(BadgeInput.allCases, id: \.self) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                TextField("Fallback label", text: $fallback)
                    .focused($editingFallback)
                    .onChange(of: editingFallback) { _, editing in
                        if editing { savedFallback = fallback }
                    }
                .textFieldStyle(.roundedBorder)
                if savedFallback != fallback {
                    Button("Undo fallback edit") { fallback = savedFallback }
                }
                Text("nickname ?? \(String(reflecting: fallback))").font(.body.monospaced())
                Text("Which value will the badge use?")
                ForEach(["Nickname", "Fallback"], id: \.self) { choice in
                    Button(choice) {
                        withAnimation(reduceMotion ? nil : .spring(duration: 0.3)) {
                            prediction = choice
                        }
                    }
                }
                if let prediction {
                    let source = input.nickname == nil ? "Fallback" : "Nickname"
                    VStack(spacing: 8) {
                        Capsule()
                            .fill(.secondary)
                            .frame(width: 32, height: 4)
                            .accessibilityHidden(true)
                        Text("Hello, my name is").font(.caption)
                        Text(display).font(.title.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.secondary.opacity(0.5))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Badge reads \(display)")
                    .transition(reduceMotion ? .identity : .scale(scale: 0.94).combined(with: .opacity))
                    Text("\(prediction == source ? "Correct." : "Try another nickname.") \(source) supplies the label. An empty string is still a value.")
                    Divider()
                    Text("A playlist title is an empty string. Will ?? supply its fallback?")
                    Button("Yes") { playlistAnswer = true }
                    Button("No") { playlistAnswer = false }
                    if let playlistAnswer {
                        Text(playlistAnswer ? "Try the empty nickname above and compare." : "Exactly. Only nil uses the fallback.")
                    }
                }
                ShareLink(item: "let nickname: String? = \(input.rawValue)\nprint(nickname ?? \(String(reflecting: fallback)))") {
                    Label("Share Swift example", systemImage: "square.and.arrow.up")
                }
                Button("Reset experiment") {
                    input = .missing
                    savedFallback = "Guest"
                    fallback = "Guest"
                    resetPrediction()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: input, resetPrediction)
            .onChange(of: fallback, resetPrediction)
        }
    }

    private func resetPrediction() {
        prediction = nil
        playlistAnswer = nil
    }
}
