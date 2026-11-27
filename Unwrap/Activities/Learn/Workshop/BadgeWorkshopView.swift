import SwiftUI

struct BadgeWorkshopView: View {
    @State private var step = 0
    @State private var reveal = false

    private static let steps = [
        ("Change a badge", "Toggle the favorite twice. Which view owns the value?", "BadgeState", "State lives in the parent. A binding lets the child change that same value."),
        ("Save favorites", "Save two badges. Close the sample app, then relaunch it. What survives?", "BadgeStorage", "SwiftData stores each badge as a model. The query reloads those models after launch."),
        ("Load a detail", "Load the project name, then leave the screen before it finishes. What cancels the request?", "BadgeLoading", "SwiftUI cancels the view task on disappearance. The cancellation check keeps stale work from updating the label."),
        ("Test a suggestion", "A suggested fix uses an empty string and nil interchangeably. Which test would catch it?", "BadgeChecks", "Check nil, an empty string, and an ordinary name. Read the accessibility label using VoiceOver as a separate check.")
    ]

    var body: some View {
        let lesson = Self.steps[step]
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Workshop step", selection: $step) {
                    ForEach(Self.steps.indices, id: \.self) { index in
                        Text(Self.steps[index].0).tag(index)
                    }
                }
                Text(lesson.1).font(.headline)
                if step == 0 { FavoriteBadgeExperiment() }
                if let url = Bundle.main.url(named: lesson.2 + ".txt"),
                   let source = try? String(contentsOf: url, encoding: .utf8) {
                    Text(step == 3 ? "Add this file to a Swift Testing target." : "Replace ContentView.swift in a new SwiftUI app with this example.")
                    SyntaxHighlightedCodeView(source: source, lineWrapping: .enabled)
                    ShareLink(item: source) { Label("Share Swift source", systemImage: "square.and.arrow.up") }
                }
                Button("Explain the result") { reveal = true }
                if reveal { Text(lesson.3) }
                if let url = URL(string: "https://www.hackingwithswift.com/100/swiftui") {
                    Link("Continue with 100 Days of SwiftUI", destination: url)
                }
            }
            .padding()
        }
        .onChange(of: step) { reveal = false }
        .navigationTitle("Badge workshop")
    }
}

private struct FavoriteBadgeExperiment: View {
    @State private var favorite = false

    var body: some View {
        Toggle(isOn: $favorite) {
            Label(favorite ? "Favorite badge" : "Guest badge", systemImage: favorite ? "star.fill" : "star")
        }
    }
}
