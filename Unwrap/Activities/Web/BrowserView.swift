//
//  BrowserView.swift
//  Unwrap
//

import SwiftUI
import WebKit

struct BrowserView: View {
    @State private var loadFailed = false
    @State private var page = WebPage()

    let url: URL

    var body: some View {
        WebView(page)
            .webViewContentBackground(.hidden)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Back", systemImage: "chevron.backward", action: goBack)
                        .disabled(page.backForwardList.backList.isEmpty)

                    Button("Forward", systemImage: "chevron.forward", action: goForward)
                        .disabled(page.backForwardList.forwardList.isEmpty)

                    if let currentURL = page.url {
                        ShareLink(
                            item: currentURL,
                            subject: Text(page.title),
                            message: Text("\(page.title) (via @twostraws)")
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button("Reload", systemImage: "arrow.clockwise", action: reload)
                        .disabled(page.isLoading)
                }
            }
            .task(id: url) {
                await performNavigation(page.load(url))
            }
    }

    private var navigationTitle: String {
        if loadFailed {
            return "Failed to load"
        }

        if let currentURL = page.url {
            if let host = currentURL.host() {
                return host
            }

            return page.title.isEmpty ? "Web" : page.title
        }

        if let host = url.host() {
            return host
        }

        return page.title.isEmpty ? "Web" : page.title
    }

    private func performNavigation<Navigation: AsyncSequence>(
        _ navigation: Navigation
    ) async where Navigation.Element == WebPage.NavigationEvent {
        loadFailed = false

        do {
            for try await _ in navigation {
            }
        } catch is CancellationError {
        } catch {
            loadFailed = true
        }
    }

    private func goBack() {
        guard let item = page.backForwardList.backList.last else { return }

        Task {
            await performNavigation(page.load(item))
        }
    }

    private func goForward() {
        guard let item = page.backForwardList.forwardList.first else { return }

        Task {
            await performNavigation(page.load(item))
        }
    }

    private func reload() {
        Task {
            await performNavigation(page.reload())
        }
    }
}
