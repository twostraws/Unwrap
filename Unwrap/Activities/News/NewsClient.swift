//
//  NewsClient.swift
//  Unwrap
//

import Foundation

/// Downloads and decodes article summaries from Hacking with Swift.
struct NewsClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    static func endpointURL(imageScale: Double) -> URL {
        let scale = max(Int(imageScale), 1)
        return URL(staticString: "https://www.hackingwithswift.com/articles/json/summary/84-@\(scale)x")
    }

    func fetchArticles(imageScale: Double) async throws -> [NewsArticle] {
        let url = Self.endpointURL(imageScale: imageScale)
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([NewsArticle].self, from: data)
    }
}
