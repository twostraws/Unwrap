//
//  LearnRoute.swift
//  Unwrap
//

import Foundation

enum LearnRoute: Hashable {
    case workshop
    case glossary
    case study(String)
    case browser(URL)
}
