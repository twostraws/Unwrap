//
//  TourPagesView.swift
//  Unwrap
//

import SwiftUI

struct TourPagesView: View {
    let items: [TourItem]
    let close: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabView {
                ForEach(items.enumerated(), id: \.offset) { _, item in
                    TourPageView(item: item)
                        // Page-style TabView places its indicator over the page content.
                        .padding(.bottom, 44)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            .padding(.top)

            Button(action: close) {
                Text("Close")
                    .font(.title)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .padding(.bottom)
        }
        .foregroundStyle(.white)
    }
}
