//
//  NewsArticle.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// One news article, downloaded from Hacking with Swift.
struct NewsArticle: Decodable {
    /// The article ID integer.
    var id: Int // swiftlint:disable:this identifier_name

    /// The headline for the article.
    var title: String

    /// The subheadline/strap/standfirst for the article.
    var strap: String

    /// The URL for the full article on the site.
    var url: URL

    /// The URL to the main image for the article at a good size for this device.
    var mainImage: URL

    /// The date this article was published.
    var publishedDate: Date
}
