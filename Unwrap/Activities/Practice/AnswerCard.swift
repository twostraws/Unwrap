//
//  AnswerCard.swift
//  Unwrap
//

import SwiftUI

extension View {
    /// Presents a stack of answer rows as a scrolling, rounded card.
    ///
    /// Practice activities use this rather than a list so the card lines up with the question above it on
    /// every device, including when it sits beside a sidebar.
    func answerCard() -> some View {
        ScrollView {
            self
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 20))
                .padding(.horizontal)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    /// Styles one row of an answer card, drawing a separator beneath every row except the last.
    func answerRow(background: Color?, isLast: Bool) -> some View {
        self
            .background {
                background
            }
            .overlay(alignment: .bottom) {
                if isLast == false {
                    Divider()
                        .padding(.leading, 20)
                }
            }
    }
}
