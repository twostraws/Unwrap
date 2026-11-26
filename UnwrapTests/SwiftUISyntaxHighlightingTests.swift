//
//  SwiftUISyntaxHighlightingTests.swift
//  UnwrapTests
//

import Testing
@testable import Unwrap

@MainActor
@Suite("SwiftUI syntax highlighting")
struct SwiftUISyntaxHighlightingTests {
    @Test("Modern declarations and result-builder bodies are highlighted")
    func swiftUICode() throws {
        let source = #"""
        import SwiftUI

        struct ProfileView<Content: View>: View {
          @Environment(\.colorScheme) private var colorScheme
          @State private var isPresented = false
          @ViewBuilder let content: () -> Content

          var body: some View {
            NavigationStack {
              VStack {
                if isPresented {
                  content()
                    .foregroundStyle(.primary)
                    .clipShape(.rect(cornerRadius: 12))
                }

                Button("Continue", systemImage: "arrow.right") {
                  isPresented.toggle()
                }
              }
            }
            .sheet(isPresented: $isPresented) {
              Text("Hello, \(colorScheme)")
            }
          }
        }

        #Preview("Profile") {
          ProfileView { Text("Preview") }
        }
        """#
        let highlighted = try SyntaxHighlighter().highlight(source, language: .swift)

        #expect(try highlighted.tokenKind(for: "import") == .keyword)
        #expect(try highlighted.tokenKind(for: "SwiftUI") == .className)
        #expect(try highlighted.tokenKind(for: "ProfileView") == .className)
        #expect(try highlighted.tokenKind(for: "View") == .className)

        for attribute in ["@Environment", "@State", "@ViewBuilder"] {
            #expect(try highlighted.tokenKind(for: attribute) == .attribute)
        }

        for keyword in ["private", "var", "let", "some", "if"] {
            #expect(try highlighted.tokenKind(for: keyword) == .keyword)
        }

        for type in ["NavigationStack", "VStack", "Button", "Text"] {
            #expect(try highlighted.tokenKind(for: type) == .className)
        }

        for function in ["foregroundStyle", "clipShape", "sheet", "toggle"] {
            #expect(try highlighted.tokenKind(for: function) == .function)
        }

        #expect(try highlighted.tokenKind(for: "\\.colorScheme") == .property)
        #expect(try highlighted.tokenKind(for: "$isPresented") == .variable)
        #expect(try highlighted.tokenKind(for: "#Preview") == .directive)
        #expect(highlighted.source == source)
        highlighted.validateRanges()
    }
}
