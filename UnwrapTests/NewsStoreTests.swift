//
//  NewsStoreTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("News store", .serialized)
@MainActor
struct NewsStoreTests {
    private final class ControlledFetcher {
        private var continuation: CheckedContinuation<[NewsArticle], any Error>?
        private(set) var requestedScales = [Double]()

        func fetchArticles(imageScale: Double) async throws -> [NewsArticle] {
            requestedScales.append(imageScale)

            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
            }
        }

        func succeed(with articles: [NewsArticle]) {
            guard let continuation else {
                preconditionFailure("No pending News request.")
            }

            self.continuation = nil
            continuation.resume(returning: articles)
        }
    }

    @Test("Only one article load can run at a time")
    func singleFlightLoading() async throws {
        let fetcher = ControlledFetcher()
        let store = NewsStore(user: User()) { scale in
            try await fetcher.fetchArticles(imageScale: scale)
        }
        let articles = [article(id: 3), article(id: 8), article(id: 5)]
        let loadingTask = Task {
            await store.load(imageScale: 2)
        }

        try await waitForRequest(in: fetcher)
        #expect(store.state == .loading)

        await store.load(imageScale: 3)
        #expect(fetcher.requestedScales == [2])

        fetcher.succeed(with: articles)
        await loadingTask.value

        #expect(store.state == .loaded)
        #expect(store.articles == articles)
    }

    @Test("Opening News records seen and read state on the user")
    func readAndSeenState() async {
        let defaults = UserDefaults.standard
        let previousTestData = defaults.data(forKey: User.testUserKey)
        defer {
            if let previousTestData {
                defaults.set(previousTestData, forKey: User.testUserKey)
            } else {
                defaults.removeObject(forKey: User.testUserKey)
            }
        }

        let articles = [article(id: 7), article(id: 12), article(id: 9)]
        let user = User()
        let store = NewsStore(user: user) { _ in articles }

        await store.load(imageScale: 2)

        #expect(store.hasNewArticles)
        #expect(user.latestNewsArticle == 0)

        store.setVisible(true)

        #expect(user.latestNewsArticle == 12)
        #expect(store.hasNewArticles == false)

        store.select(.article(articles[0]))

        #expect(store.isRead(articles[0]))
        #expect(user.hasReadNewsStory(forURL: articles[0].url))
        #expect(User.load(testMode: true)?.hasReadNewsStory(forURL: articles[0].url) == true)
        #expect(User.load(testMode: true)?.latestNewsArticle == 12)
    }

    @Test("A failed load reports failure and a later retry recovers")
    func failureThenRetry() async {
        let articles = [article(id: 4)]
        let responses = ScriptedResponses([.failure(URLError(.notConnectedToInternet)), .success(articles)])
        let store = NewsStore(user: User()) { _ in try responses.next() }

        await store.load(imageScale: 2)

        #expect(store.state == .failed)
        #expect(store.articles.isEmpty)
        #expect(store.hasNewArticles == false)

        await store.load(imageScale: 2)

        #expect(store.state == .loaded)
        #expect(store.articles == articles)
        #expect(store.hasNewArticles)
    }

    @Test("An empty article list counts as a failed load")
    func emptyResponse() async {
        let store = NewsStore(user: User()) { _ in [] }

        await store.load(imageScale: 2)

        #expect(store.state == .failed)
        #expect(store.hasNewArticles == false)
    }

    @Test("A cancelled first load returns to idle so it can run again")
    func cancelledFirstLoad() async {
        let store = NewsStore(user: User()) { _ in throw CancellationError() }

        await store.load(imageScale: 2)

        #expect(store.state == .idle)
        #expect(store.articles.isEmpty)
    }

    @Test("A cancelled refresh keeps the articles that were already showing")
    func cancelledRefresh() async {
        let articles = [article(id: 4), article(id: 6)]
        let responses = ScriptedResponses([.success(articles), .failure(URLError(.cancelled))])
        let store = NewsStore(user: User()) { _ in try responses.next() }

        await store.load(imageScale: 2)
        await store.load(imageScale: 2)

        #expect(store.state == .loaded)
        #expect(store.articles == articles)
    }

    @Test("Articles that arrive while News is on screen are seen straight away")
    func loadingWhileVisible() async {
        let user = User()
        let store = NewsStore(user: user) { _ in [self.article(id: 3), self.article(id: 21)] }

        store.setVisible(true)
        #expect(user.latestNewsArticle == 0)

        await store.load(imageScale: 2)

        #expect(user.latestNewsArticle == 21)
        #expect(store.hasNewArticles == false)
    }

    @Test("Only articles newer than the last one seen raise the new-articles flag")
    func newArticleDetection() async {
        let user = User()
        user.seenUpToArticle(12)
        let responses = ScriptedResponses([
            .success([article(id: 7), article(id: 12)]),
            .success([article(id: 7), article(id: 12), article(id: 13)])
        ])
        let store = NewsStore(user: user) { _ in try responses.next() }

        await store.load(imageScale: 2)
        #expect(store.hasNewArticles == false)

        await store.load(imageScale: 2)
        #expect(store.hasNewArticles)
        #expect(user.latestNewsArticle == 12)
    }

    @Test("Leaving News doesn't bring the new-articles flag back")
    func hidingAfterSeeing() async {
        let user = User()
        let store = NewsStore(user: user) { _ in [self.article(id: 30)] }

        await store.load(imageScale: 2)
        store.setVisible(true)
        store.setVisible(false)

        #expect(store.isVisible == false)
        #expect(store.hasNewArticles == false)
        #expect(user.latestNewsArticle == 30)
    }

    @Test("Opening an article twice counts it as read once")
    func repeatedSelection() {
        let user = User()
        let store = NewsStore(user: user) { _ in [] }
        let first = article(id: 1)
        let second = article(id: 2)

        store.select(.article(first))
        store.select(.article(second))
        store.select(.article(first))

        #expect(store.selectedRoute == .article(first))
        #expect(user.readNewsCount == 2)
        #expect(store.isRead(first))
        #expect(store.isRead(second))
        #expect(store.isRead(article(id: 3)) == false)
    }

    @Test("The books route and a cleared selection never mark anything as read")
    func nonArticleSelections() {
        let user = User()
        let store = NewsStore(user: user) { _ in [] }

        store.openBooks()
        #expect(store.selectedRoute == .buySwiftBooks)

        store.select(nil)
        #expect(store.selectedRoute == nil)
        #expect(user.readNewsCount == 0)
    }

    /// Hands back one prepared response per request, in order.
    private final class ScriptedResponses {
        private var responses: [Result<[NewsArticle], any Error>]

        init(_ responses: [Result<[NewsArticle], any Error>]) {
            self.responses = responses
        }

        func next() throws -> [NewsArticle] {
            guard responses.isEmpty == false else {
                preconditionFailure("More News requests were made than responses were scripted.")
            }

            return try responses.removeFirst().get()
        }
    }

    private func article(id: Int) -> NewsArticle {
        NewsArticle(
            id: id,
            title: "Article \(id)",
            strap: "Strap \(id)",
            url: URL(staticString: "https://example.com/articles/\(id)"),
            mainImage: URL(staticString: "https://example.com/images/\(id).png")
        )
    }

    private func waitForRequest(in fetcher: ControlledFetcher) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(5))

        while fetcher.requestedScales.isEmpty {
            try #require(clock.now < deadline, "Timed out waiting for the News request.")
            await Task.yield()
        }
    }
}
