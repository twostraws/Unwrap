//
//  NewsClientTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@Suite("News client", .serialized)
struct NewsClientTests {
    private enum StubError: Error {
        case invalidRequest
        case missingHandler
    }

    nonisolated private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
        nonisolated(unsafe) static var handler:
            (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

        override class func canInit(with request: URLRequest) -> Bool { // swiftlint:disable:this static_over_final_class
            true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest { // swiftlint:disable:this static_over_final_class
            request
        }

        override func startLoading() {
            guard let handler = Self.handler else {
                client?.urlProtocol(self, didFailWithError: StubError.missingHandler)
                return
            }

            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }

        override func stopLoading() {
        }
    }

    @Test("Fetches the scaled endpoint and decodes article summaries")
    @MainActor
    func fetchArticles() async throws {
        let json = """
        [
          {
            "id": 4,
            "title": "First article",
            "strap": "First strap",
            "url": "https://www.hackingwithswift.com/articles/4/first",
            "main_image": "https://www.hackingwithswift.com/uploads/4.png"
          },
          {
            "id": 11,
            "title": "Second article",
            "strap": "Second strap",
            "url": "https://www.hackingwithswift.com/articles/11/second",
            "main_image": "https://www.hackingwithswift.com/uploads/11.png"
          }
        ]
        """
        let session = makeSession(statusCode: 200, body: json) { request in
            request.url?.absoluteString ==
                "https://www.hackingwithswift.com/articles/json/summary/84-@2x"
        }
        defer { finish(session) }

        let articles = try await NewsClient(session: session).fetchArticles(imageScale: 2)

        #expect(articles.map(\.id) == [4, 11])
        #expect(articles.map(\.title) == ["First article", "Second article"])
        #expect(articles[0].mainImage.absoluteString == "https://www.hackingwithswift.com/uploads/4.png")
    }

    @Test("Rejects unsuccessful HTTP responses")
    @MainActor
    func rejectsHTTPFailure() async {
        let session = makeSession(statusCode: 503, body: "Unavailable")
        defer { finish(session) }

        do {
            _ = try await NewsClient(session: session).fetchArticles(imageScale: 3)
            Issue.record("Expected an unsuccessful response to throw.")
        } catch let error as URLError {
            #expect(error.code == .badServerResponse)
        } catch {
            Issue.record("Expected URLError.badServerResponse, got \(error).")
        }
    }

    @Test("Rejects malformed article JSON")
    @MainActor
    func rejectsMalformedJSON() async {
        let session = makeSession(statusCode: 200, body: "not-json")
        defer { finish(session) }

        do {
            _ = try await NewsClient(session: session).fetchArticles(imageScale: 1)
            Issue.record("Expected malformed JSON to throw.")
        } catch {
            #expect(error is DecodingError)
        }
    }

    private func makeSession(
        statusCode: Int,
        body: String,
        validatesRequest: @escaping @Sendable (URLRequest) -> Bool = { _ in true }
    ) -> URLSession {
        URLProtocolStub.handler = { request in
            guard validatesRequest(request),
                  let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: statusCode,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                throw StubError.invalidRequest
            }

            return (response, Data(body.utf8))
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    private func finish(_ session: URLSession) {
        session.invalidateAndCancel()
        URLProtocolStub.handler = nil
    }
}
