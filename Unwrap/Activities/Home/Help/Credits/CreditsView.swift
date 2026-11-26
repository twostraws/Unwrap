//
//  CreditsView.swift
//  Unwrap
//

import SwiftUI

struct CreditsView: View {
    let markdown: String
    let openWebURL: (URL) -> Void

    var body: some View {
        ScrollView {
            MarkdownText(markdown: markdown)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
        }
        .navigationTitle("Credits")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.openURL, OpenURLAction { url in
            if url.scheme == "http" || url.scheme == "https" {
                openWebURL(url)
                return .handled
            }

            return .systemAction
        })
    }
}
