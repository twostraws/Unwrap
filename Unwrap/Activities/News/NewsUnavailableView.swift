//
//  NewsUnavailableView.swift
//  Unwrap
//

import SwiftUI

struct NewsUnavailableView: View {
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            VStack {
                NewsPlaceholderImage()
                    .frame(width: 84, height: 56)

                Text("News")
                    .font(.headline)
            }
        } description: {
            Text("We couldn't download the news right now. Please tap the button below to try again.")
        } actions: {
            Button("Try Again", action: retry)
                .font(.callout)
        }
    }
}
