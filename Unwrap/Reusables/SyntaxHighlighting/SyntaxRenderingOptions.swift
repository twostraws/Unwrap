//
//  SyntaxRenderingOptions.swift
//  Unwrap
//

nonisolated struct SyntaxRenderingOptions: Sendable {
    let lineWrapping: CodeLineWrapping

    init(lineWrapping: CodeLineWrapping = .disabled) {
        self.lineWrapping = lineWrapping
    }
}
