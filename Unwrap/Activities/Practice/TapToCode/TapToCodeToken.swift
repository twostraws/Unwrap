//
//  TapToCodeToken.swift
//  Unwrap
//

struct TapToCodeToken: Hashable, Identifiable {
    let id: Int
    let text: String
}

/// The two places a token can sit: in the learner's code, or waiting to be used.
nonisolated enum TapToCodeArea: Hashable, Sendable {
    case used
    case available
}
