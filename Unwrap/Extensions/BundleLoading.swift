//
//  BundleLoading.swift
//  Unwrap
//

import Foundation

extension Bundle {
    func data(named name: String) throws -> Data {
        guard let url = url(named: name) else {
            throw BundleResourceError.missingResource(name)
        }

        return try Data(contentsOf: url)
    }

    func decode<T: Decodable>(_ type: T.Type, from name: String) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data(named: name))
    }

    func text(named name: String) throws -> String {
        let data = try data(named: name)

        guard let result = String(data: data, encoding: .utf8) else {
            throw BundleResourceError.unreadableText(name)
        }

        return result
    }

    func url(named name: String) -> URL? {
        url(forResource: name, withExtension: nil)
    }
}
