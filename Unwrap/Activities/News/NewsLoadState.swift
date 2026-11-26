//
//  NewsLoadState.swift
//  Unwrap
//

/// The complete set of user-visible News loading states.
enum NewsLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed
}
