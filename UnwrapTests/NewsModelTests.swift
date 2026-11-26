//
//  NewsModelTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("News models")
struct NewsModelTests {
    @Test("Article and book routes preserve their destinations")
    func routes() {
        let article = NewsArticle(
            id: 7,
            title: "Swift Concurrency",
            strap: "A useful article",
            url: URL(staticString: "https://example.com/articles/7"),
            mainImage: URL(staticString: "https://example.com/images/7.png")
        )

        #expect(article.id == 7)
        #expect(NewsRoute.article(article).url == article.url)
        #expect(NewsRoute.buySwiftBooks.url.absoluteString == "https://www.hackingwithswift.com/store")
    }
}
