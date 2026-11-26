//
//  PracticePromptText.swift
//  Unwrap
//

import SwiftUI

struct PracticePromptText: View {
    let markdown: String
    let explanation: String?

    init(markdown: String, explanation: String? = nil) {
        self.markdown = markdown
        self.explanation = explanation
    }

    var body: some View {
        MarkdownText(markdown: combinedMarkdown)
            .font(.headline)
            .promptCard()
    }

    private var combinedMarkdown: String {
        guard let explanation, explanation.isEmpty == false else { return markdown }
        return "\(markdown)\n\n\(explanation)"
    }
}
