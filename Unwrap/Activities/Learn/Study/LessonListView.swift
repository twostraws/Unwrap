//
//  LessonListView.swift
//  Unwrap
//

import SwiftUI

struct LessonListView: View {
    let items: [String]
    let isNumbered: Bool

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline) {
                    Text(isNumbered ? "\(index + 1)." : "•")
                        .accessibilityHidden(true)

                    Text(LessonMarkdownFormatter.attributedString(from: items[index]))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.horizontal)
    }
}
