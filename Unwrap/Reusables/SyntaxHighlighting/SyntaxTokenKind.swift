//
//  SyntaxTokenKind.swift
//  Unwrap
//

nonisolated enum SyntaxTokenKind: String, CaseIterable, Hashable, Sendable {
    case plain
    case comment
    case documentationComment
    case keyword
    case builtin
    case boolean
    case number
    case string
    case regex
    case `operator`
    case identifier
    case variable
    case function
    case className
    case property
    case attribute
    case directive
    case tag
    case selector
    case title
    case bold
    case italic
    case code
}
