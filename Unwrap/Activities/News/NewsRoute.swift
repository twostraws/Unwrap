//
//  NewsRoute.swift
//  Unwrap
//

import Foundation

/// A typed destination presented by the News split view.
enum NewsRoute: Hashable {
    case article(NewsArticle)
    case buySwiftBooks

    static let buySwiftBooksURL: URL = {
        guard let url = URL(string: "https://www.hackingwithswift.com/store") else {
            preconditionFailure("The Hacking with Swift store URL must be valid.")
        }

        return url
    }()

    var url: URL {
        switch self {
        case .article(let article):
            article.url
        case .buySwiftBooks:
            Self.buySwiftBooksURL
        }
    }
}
