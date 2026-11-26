//
//  NewsView.swift
//  Unwrap
//

import SwiftUI

struct NewsView: View {
    @Environment(\.displayScale) private var displayScale
    let store: NewsStore

    var body: some View {
        NavigationSplitView {
            NewsListView(store: store, imageScale: Double(displayScale))
        } detail: {
            NewsDetailView(route: store.selectedRoute)
        }
        .onAppear {
            store.setVisible(true)
        }
        .onDisappear {
            store.setVisible(false)
        }
        .task {
            if store.state == .idle {
                await store.load(imageScale: Double(displayScale))
            }
        }
    }
}
