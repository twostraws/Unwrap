//
//  BundleResourceError.swift
//  Unwrap
//

enum BundleResourceError: Error, Equatable {
    case missingResource(String)
    case unreadableText(String)
}
