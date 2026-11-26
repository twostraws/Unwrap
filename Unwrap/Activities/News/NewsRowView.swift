//
//  NewsRowView.swift
//  Unwrap
//

import SwiftUI

struct NewsRowView: View {
    let article: NewsArticle
    let isRead: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 6) {
                NewsThumbnailView(url: article.mainImage)

                if isRead == false {
                    Text("NEW")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color("BrandPrimary"), in: .capsule)
                        .accessibilityHidden(true)
                }
            }

            Text(article.title)
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(isRead ? "Read" : "Unread")
    }
}
