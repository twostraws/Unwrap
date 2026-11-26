//
//  NewsStore.swift
//  Unwrap
//

import SwiftUI

/// Owns News loading, navigation, visibility, and read/seen decisions.
@Observable
final class NewsStore {
    private(set) var state = NewsLoadState.idle
    private(set) var articles = [NewsArticle]()
    private(set) var selectedRoute: NewsRoute?
    private(set) var isVisible = false
    private(set) var hasNewArticles = false

    @ObservationIgnored private let fetchArticles: (Double) async throws -> [NewsArticle]
    @ObservationIgnored private let user: User

    init(
        user: User,
        fetchArticles: @escaping (Double) async throws -> [NewsArticle] = {
            try await NewsClient().fetchArticles(imageScale: $0)
        }
    ) {
        self.user = user
        self.fetchArticles = fetchArticles
    }

    private var newestArticleID: Int? {
        articles.map(\.id).max()
    }

    func load(imageScale: Double) async {
        guard state != .loading else { return }

        let cancellationRecoveryState = state
        state = .loading

        do {
            let fetchedArticles = try await fetchArticles(imageScale)
            try Task.checkCancellation()

            articles = fetchedArticles
            state = fetchedArticles.isEmpty ? .failed : .loaded
            synchronizeSeenState()
        } catch {
            if error is CancellationError
                || (error as? URLError)?.code == .cancelled {
                state = cancellationRecoveryState
            } else {
                state = .failed
            }

            synchronizeSeenState()
        }
    }

    func setVisible(_ visible: Bool) {
        isVisible = visible
        synchronizeSeenState()
    }

    func select(_ route: NewsRoute?) {
        selectedRoute = route

        guard case .article(let article) = route else { return }
        markReadIfNeeded(article)
    }

    func openBooks() {
        select(.buySwiftBooks)
    }

    func isRead(_ article: NewsArticle) -> Bool {
        user.hasReadNewsStory(forURL: article.url)
    }

    /// Reconciles user state after a load, visibility change, or external user update.
    func synchronizeSeenState() {
        guard isVisible else {
            let hasUnseenArticle = newestArticleID.map { $0 > user.latestNewsArticle } ?? false
            setHasNewArticles(hasUnseenArticle)
            return
        }

        if let newestArticleID, newestArticleID > user.latestNewsArticle {
            user.seenUpToArticle(newestArticleID)
        }

        setHasNewArticles(false)
    }

    private func markReadIfNeeded(_ article: NewsArticle) {
        guard isRead(article) == false else { return }

        user.readNewsStory(forURL: article.url)
    }

    private func setHasNewArticles(_ newValue: Bool) {
        guard hasNewArticles != newValue else { return }

        hasNewArticles = newValue
    }
}
