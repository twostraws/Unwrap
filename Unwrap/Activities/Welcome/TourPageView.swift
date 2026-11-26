//
//  TourPageView.swift
//  Unwrap
//

import SwiftUI

struct TourPageView: View {
    let item: TourItem

    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .aspectRatio(3 / 2, contentMode: .fit)
                .overlay {
                    Image(item.image)
                        .resizable()
                        .scaledToFill()
                }
                .accessibilityHidden(true)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("BrandSecondary"), lineWidth: 1)
                }

            Text(item.title)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)

            ScrollView {
                Text(item.text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.visible)
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding(.horizontal, 20)
    }
}
