//
//  Swift64SyntaxHighlightingTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

@MainActor
@Suite("Swift 6.4 syntax highlighting")
struct Swift64SyntaxHighlightingTests {
    @Test("String interpolation recursively highlights complex expressions")
    func nestedInterpolation() throws {
        let source = #"""
        let message = "Total: \(items.compactMap { $0 ?? fallback() }.reduce(0, +))"
        """#
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(try highlighted.tokenKind(for: "let") == .keyword)
        #expect(try highlighted.tokenKind(for: "\"Total: ") == .string)
        #expect(try highlighted.tokenKind(for: "??") == .operator)
        #expect(try highlighted.tokenKind(for: "fallback") == .function)
        #expect(try highlighted.tokenKind(for: "0") == .number)
        #expect(highlighted.tokens.contains { $0.scopes.contains("interpolation") })
    }

    @Test("Raw multiline strings preserve delimiters and highlight interpolation")
    func rawMultilineStrings() throws {
        let source = ##"""
        let message = #"""
        First line
        Value: \#(items[0] ?? "none")
        """#
        """##
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(try highlighted.tokenKind(for: "#\"\"\"") == .string)
        #expect(try highlighted.tokenKind(for: "??") == .operator)
        #expect(try highlighted.tokenKind(for: "\"none\"") == .string)
        #expect(try highlighted.tokenKind(for: "0") == .number)
        #expect(highlighted.source == source)
    }

    @Test("Nested comments, documentation comments, and directives are distinct")
    func commentsAndDirectives() throws {
        let source = """
        /// Creates a value.
        #if compiler(>=6.4)
        /* outer /* nested */ finished */
        let value = 0xFF_FF
        #endif
        """
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(try highlighted.tokenKind(for: "/// Creates a value.") == .documentationComment)
        #expect(try highlighted.tokenKind(for: "#if") == .directive)
        #expect(try highlighted.tokenKind(for: "/* outer /* nested */ finished */") == .comment)
        #expect(try highlighted.tokenKind(for: "0xFF_FF") == .number)
        #expect(try highlighted.tokenKind(for: "#endif") == .directive)
    }

    @Test("Range operators stay separate from every numeric literal form")
    func numbersAndRanges() throws {
        let source = """
        let values = 1...5
        let slice = 0..<5
        let decimal = 3.141_592
        let exponent = 1.25e-3
        let binary = 0b1010_0110
        let octal = 0o755
        let hexadecimal = 0xFF_A0
        let hexFloat = 0x1.fp2
        """
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        for number in ["1", "5", "0", "3.141_592", "1.25e-3", "0b1010_0110", "0o755", "0xFF_A0", "0x1.fp2"] {
            #expect(try highlighted.tokenKind(for: number) == .number)
        }

        #expect(try highlighted.tokenKind(for: "...") == .operator)
        #expect(try highlighted.tokenKind(for: "..<") == .operator)
    }

    @Test("Closures, optionals, ownership, attributes, macros, and regex literals")
    func modernSwiftSurface() throws {
        let source = ##"""
        @MainActor
        @Observable
        final class Store<T: ~Copyable> {
          let transform: @Sendable (borrowing T?) async throws -> String

          func value(_ input: consuming T?) async rethrows -> String {
            try await transform(input ?? nil)
          }
        }

        let regex = #/user-(\d+)-\#(suffix)/#
        let closure = { [weak self] (value: Int?) -> Int in
          value ?? self?.fallback ?? 0
        }

        #externalMacro(module: "Macros", type: "ExampleMacro")
        """##
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        for attribute in ["@MainActor", "@Observable", "@Sendable"] {
            #expect(try highlighted.tokenKind(for: attribute) == .attribute)
        }

        for keyword in ["final", "class", "borrowing", "async", "throws", "consuming", "rethrows", "weak", "in"] {
            let actualKind = try highlighted.tokenKind(for: keyword)
            #expect(actualKind == .keyword, "Expected \(keyword) to be a keyword, got \(actualKind)")
        }

        #expect(try highlighted.tokenKind(for: "Store") == .className)
        #expect(try highlighted.tokenKind(for: "??") == .operator)
        #expect(try highlighted.tokenKind(for: "#/user-(\\d+)-\\#(suffix)/#") == .regex)
        #expect(try highlighted.tokenKind(for: "#externalMacro") == .directive)
    }

    @Test("Bare regex literals are distinguished from division operators")
    func bareRegexAndDivision() throws {
        let source = #"""
        let matcher = /user-(\d+)-[a-z/]+/
        let quotient = total / count
        """#
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(try highlighted.tokenKind(for: #"/user-(\d+)-[a-z/]+/"#) == .regex)
        #expect(
            highlighted.tokens.contains {
                $0.kind == .operator && String(source[$0.range]) == "/"
            }
        )
    }

    @Test("Swift 6.4 additions receive first-class highlighting")
    func swift64Additions() throws {
        let source = """
        @diagnose(DeprecatedDeclaration, as: warning, reason: "Temporary bridge")
        func bridge() async {
          defer {
            await cleanup()
          }
        }

        struct Storage<Value: ~Copyable> {
          var value: Value {
            borrow { return storage }
            mutate { return &storage }
          }

          var yieldedValue: Value {
            yielding borrow { yield storage }
            yielding mutate { yield &storage }
          }
        }

        struct DeliberatelyLocal: ~Sendable {}

        func optionalContent() -> some View? {
          EmptyView()
        }

        func acceptsOptionalView(_ value: any View?) {}

        let values = [String] {
          "one"
          "two"
        }
        """
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(try highlighted.tokenKind(for: "@diagnose") == .attribute)
        for keyword in ["defer", "await", "yielding", "borrow", "yield", "mutate", "some", "any"] {
            #expect(try highlighted.tokenKind(for: keyword) == .keyword)
        }
        #expect(try highlighted.tokenKind(for: "String") == .className)
        #expect(try highlighted.tokenKind(for: "Sendable") == .className)
        #expect(try highlighted.tokenKind(for: "~") == .operator)
        #expect(highlighted.source == source)
    }

    @Test("Reserved and modern contextual words receive keyword styling")
    func languageKeywords() throws {
        let keywords = [
            "Any", "Self", "Protocol", "Type", "actor", "any", "as", "associatedtype",
            "associativity", "async", "await", "borrow", "borrowing", "break", "case",
            "catch", "class", "consume", "consuming", "continue", "convenience", "copy",
            "default", "defer", "deinit", "didSet", "discard", "distributed", "do", "dynamic",
            "each", "else", "enum", "extension", "fallthrough", "false", "fileprivate", "final",
            "for", "func", "get", "guard", "higherThan", "if", "import", "in", "indirect",
            "infix", "init", "initializes", "inout", "internal", "is", "isolated", "lazy",
            "left", "let", "lowerThan", "macro", "modify", "mutate", "mutating", "nil", "none",
            "nonisolated", "nonmutating", "nonsending", "open", "operator", "optional", "override",
            "package", "postfix", "precedence", "precedencegroup", "prefix", "private", "protocol",
            "public", "read", "repeat", "required", "rethrows", "return", "right", "safe",
            "scoped", "self", "sending", "set", "some", "static", "struct", "subscript", "super",
            "switch", "then", "throw", "throws", "true", "try", "typealias", "unowned", "unsafe",
            "using", "var", "weak", "where", "while", "willSet", "yield", "yielding", "_"
        ]
        let source = keywords.joined(separator: " ")
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        for keyword in keywords {
            #expect(try highlighted.tokenKind(for: keyword) == .keyword)
        }
    }

    @Test("Multiline escapes, rooted key paths, and return-position regexes stay intact")
    func additionalLiteralBoundaries() throws {
        let source = ##"""
        let text = """
        An escaped delimiter: \"""
        Still inside the string
        """

        func matcher() -> Regex<Substring> {
          return /user\/[a-z]+/
        }

        let name = \Person.name
        """##
        let multilineString = "\"\"\"\nAn escaped delimiter: \\\"\"\"\nStill inside the string\n\"\"\""
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(try highlighted.tokenKind(for: multilineString) == .string)
        #expect(try highlighted.tokenKind(for: "/user\\/[a-z]+/") == .regex)
        #expect(try highlighted.tokenKind(for: "\\Person.name") == .property)
        highlighted.validateRanges()
    }
}
