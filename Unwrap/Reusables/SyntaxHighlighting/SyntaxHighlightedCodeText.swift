//
//  SyntaxHighlightedCodeText.swift
//  Unwrap
//

import SwiftUI

struct SyntaxHighlightedCodeText: View {
    let attributedCode: AttributedString
    let source: String
    let lineWrapping: CodeLineWrapping

    var body: some View {
        Text(attributedCode)
            .fixedSize(horizontal: lineWrapping.allowsWrapping == false, vertical: true)
            .frame(maxWidth: lineWrapping.allowsWrapping ? .infinity : nil, alignment: .leading)
            .padding()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Code")
            .accessibilityValue(source)
    }
}
