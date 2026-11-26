//
//  LessonContentView.swift
//  Unwrap
//

import SwiftUI

struct LessonContentView: View {
    @ScaledMetric(relativeTo: .body) private var blockSpacing: CGFloat = 16

    let lesson: Lesson
    let content: LessonContent
    let playVideo: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: blockSpacing) {
                if lesson.videoURL != nil {
                    Button(action: playVideo) {
                        Label {
                            Text("Play Video")
                        } icon: {
                            Image(lesson.id)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        }
                        .labelStyle(.iconOnly)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Play video: \(lesson.title)")
                } else {
                    Image(lesson.id)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }

                ForEach(content.blocks.indices, id: \.self) { index in
                    switch content.blocks[index] {
                    case .text(let markdown):
                        Text(LessonMarkdownFormatter.attributedString(from: markdown))
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    case .code(let source):
                        SyntaxHighlightedCodeView(source: source, lineWrapping: .enabled)
                    case .bullets(let items):
                        LessonListView(items: items, isNumbered: false)
                    case .numbered(let items):
                        LessonListView(items: items, isNumbered: true)
                    }
                }
            }
            .padding(.bottom)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }
}
