//
//  NewsPlaceholderImage.swift
//  Unwrap
//

import SwiftUI

struct NewsPlaceholderImage: View {
    var body: some View {
        Rectangle()
            .fill(.quaternary)
            .overlay {
                Image(systemName: "newspaper")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .accessibilityHidden(true)
    }
}
