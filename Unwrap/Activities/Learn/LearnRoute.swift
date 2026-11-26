//
//  LearnRoute.swift
//  Unwrap
//

import Foundation

enum LearnRoute: Hashable {
    case glossary
    case study(String)
    case browser(URL)
}
