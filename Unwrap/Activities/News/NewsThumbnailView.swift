//
//  NewsThumbnailView.swift
//  Unwrap
//

import SwiftUI

struct NewsThumbnailView: View {
    @Environment(\.displayScale) private var displayScale

    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                NewsPlaceholderImage()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                NewsPlaceholderImage()
            @unknown default:
                NewsPlaceholderImage()
            }
        }
        .frame(width: 84, height: 56)
        .clipShape(.rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.gray.opacity(0.5), lineWidth: 1 / max(displayScale, 1))
        }
        .accessibilityHidden(true)
    }
}
