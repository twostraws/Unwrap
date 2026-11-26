//
//  HomeShareLink.swift
//  Unwrap
//

import SwiftUI

/// A share button for a score or badge, sending its artwork together with a short message.
struct HomeShareLink: View {
    let title: String
    let item: HomeShareItem

    var body: some View {
        ShareLink(
            title,
            item: item,
            message: Text(item.text),
            preview: SharePreview(item.title, image: previewImage)
        )
    }

    private var previewImage: Image {
        switch item.artwork {
        case .image(let name):
            Image(name)
        case .badge(let symbolName):
            Image(systemName: symbolName)
        }
    }
}
