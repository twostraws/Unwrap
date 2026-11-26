//
//  NewsListView.swift
//  Unwrap
//

import SwiftUI

struct NewsListView: View {
    @Bindable var store: NewsStore

    let imageScale: Double

    var body: some View {
        let selection = Binding<NewsRoute?>(
            get: { store.selectedRoute },
            set: { store.select($0) }
        )

        Group {
            if store.articles.isEmpty {
                switch store.state {
                case .idle, .loading:
                    ProgressView("Loading News")
                case .failed:
                    NewsUnavailableView(retry: retry)
                case .loaded:
                    EmptyView()
                }
            } else {
                List(selection: selection) {
                    ForEach(store.articles) { article in
                        let route = NewsRoute.article(article)

                        NavigationLink(value: route) {
                            NewsRowView(article: article, isRead: store.isRead(article))
                        }
                        .tag(route)
                        .contextMenu {
                            EmptyView()
                        } preview: {
                            NavigationStack {
                                BrowserView(url: article.url)
                            }
                        }
                    }
                }
                .refreshable {
                    await store.load(imageScale: imageScale)
                }
            }
        }
        .navigationTitle("News")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Buy Swift Books") {
                    store.openBooks()
                }
            }
        }
    }

    private func retry() {
        Task {
            await store.load(imageScale: imageScale)
        }
    }
}
