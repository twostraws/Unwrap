//
//  NewsArticle.swift
//  Unwrap
//

import Foundation

/// A summary of one article returned by the Hacking with Swift News endpoint.
struct NewsArticle: Decodable, Hashable, Identifiable {
    let id: Int
    let title: String
    let strap: String
    let url: URL
    let mainImage: URL
}
