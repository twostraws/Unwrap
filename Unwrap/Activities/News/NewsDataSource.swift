//
//  NewsDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import SDWebImage
import UIKit

/// Manages all the rows in the News table view.
class NewsDataSource: NSObject, UITableViewDataSource {
    /// A delegate where we can report back when loading finishes.
    weak var delegate: NewsViewController?

    /// The array of articles we downloaded from the site.
    private var articles = [NewsArticle]()

    /// When read, returns whether we're storing articles the user hasn't seen yet (i.e. visited the News tab as opposed to actually reading). When written, stores that the user has seen up to the latest article ID.
    var containsNewArticles: Bool {
        get {
            if let newestArticleID = articles.first?.id {
                if newestArticleID > User.current.latestNewsArticle {
                    return true
                }
            }

            return false
        }

        set {
            if let newestArticleID = articles.first?.id {
                User.current.seenUpToArticle(newestArticleID)
            }
        }
    }

    /// Downloads the latest news from Hacking with Swift.
    func fetchArticles() {
        DispatchQueue.global().async {
            // Request images that are 84 points wide at whatever scale the device uses. 84 was arrived through testing – it's the largest that still looks good in iPhone SE, while still giving us a 3:2 aspect ratio.

            let scale = Int(UIScreen.main.scale)
            let url = URL(staticString: "https://www.hackingwithswift.com/articles/json/summary/84-@\(scale)x")

            do {
                // Convert the data to NewsArticle instances.
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let decodedArticles = try decoder.decode([NewsArticle].self, from: data)
                self.articles = decodedArticles

                // Loading is done, so update the UI.
                DispatchQueue.main.async {
                    self.delegate?.finishedLoadingArticles()
                }
            } catch {
                // There's no point putting an error message here, because it just doesn't matter – the user was probably just offline or stuck on a weak connection.
//                print("Failed to load JSON: \(error.localizedDescription).")
            }
        }
    }

    /// Send back one row for each article.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    /// Configure cells with their title, strap, and a placeholder image. SDWebImage then downloads the correct image for us.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            fatalError("Unable to dequeue cell.")
        }

        guard let newsCell = cell as? NewsTableViewCell else {
            fatalError("Unable to create cell as a NewsTableViewCell.")
        }

        let article = articles[indexPath.row]

        if User.current.hasReadNewsStory(forURL: article.url) {
            newsCell.readNotification.alpha = 0
        } else {
            newsCell.readNotification.alpha = 1
        }

        newsCell.textLabel?.text = article.title
        newsCell.detailTextLabel?.text = article.strap

        newsCell.imageView?.sd_cancelCurrentImageLoad()
        newsCell.imageView?.sd_setImage(with: article.mainImage, placeholderImage: UIImage(bundleName: "News-Placeholder"))

        // draw a micro-width border around images so that white images don't just spill over to the rest of the cell
        newsCell.imageView?.layer.borderWidth = 1 / UIScreen.main.scale
        newsCell.imageView?.layer.borderColor = UIColor.lightGray.cgColor

        return newsCell
    }

    /// Lets our own read articles without digging directly into the articles array.
    func article(at index: Int) -> NewsArticle {
        return articles[index]
    }
}
