//
//  PromptCard.swift
//  Unwrap
//

import SwiftUI

extension View {
    /// Presents a question as a rounded card that sits clear of the navigation bar, rather than running behind it.
    func promptCard() -> some View {
        self
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color("BackgroundDark"), in: .rect(cornerRadius: 20))
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, 12)
    }
}
