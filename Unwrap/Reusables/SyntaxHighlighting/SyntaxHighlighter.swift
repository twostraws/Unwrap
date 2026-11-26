//
//  SyntaxHighlighter.swift
//  Unwrap
//

nonisolated struct SyntaxHighlighter: Sendable {
    private let grammars: [SyntaxLanguage: any SyntaxGrammar]
    let registeredLanguages: Set<SyntaxLanguage>

    /// Creates a highlighter, allowing callers to replace bundled grammars or add new languages.
    init(additionalGrammars: [SyntaxLanguage: any SyntaxGrammar] = [:]) {
        var registeredGrammars: [SyntaxLanguage: any SyntaxGrammar] = [
            .bash: BashSyntaxGrammar(),
            .c: CSyntaxGrammar(),
            .cpp: CppSyntaxGrammar(),
            .cSharp: CSharpSyntaxGrammar(),
            .css: CSSSyntaxGrammar(),
            .dart: DartSyntaxGrammar(),
            .go: GoSyntaxGrammar(),
            .graphql: GraphQLSyntaxGrammar(),
            .java: JavaSyntaxGrammar(),
            .javascript: JavaScriptSyntaxGrammar(),
            .json: JSONSyntaxGrammar(),
            .jsx: JSXSyntaxGrammar(),
            .kotlin: KotlinSyntaxGrammar(),
            .lua: LuaSyntaxGrammar(),
            .markdown: MarkdownSyntaxGrammar(),
            .markup: MarkupSyntaxGrammar(),
            .objectiveC: ObjectiveCSyntaxGrammar(),
            .php: PHPSyntaxGrammar(),
            .powershell: PowerShellSyntaxGrammar(),
            .python: PythonSyntaxGrammar(),
            .ruby: RubySyntaxGrammar(),
            .rust: RustSyntaxGrammar(),
            .scala: ScalaSyntaxGrammar(),
            .sql: SQLSyntaxGrammar(),
            .swift: SwiftSyntaxGrammar(),
            .tsx: TSXSyntaxGrammar(),
            .typescript: TypeScriptSyntaxGrammar(),
            .yaml: YAMLSyntaxGrammar()
        ]

        registeredGrammars.merge(additionalGrammars) { _, customGrammar in customGrammar }
        grammars = registeredGrammars
        registeredLanguages = Set(registeredGrammars.keys)
    }

    func highlight(_ source: String, language: SyntaxLanguage) throws -> HighlightedCode {
        guard let grammar = grammars[language] else {
            throw SyntaxHighlightingError.unsupportedLanguage(language.rawValue)
        }

        return HighlightedCode(
            source: source,
            language: language,
            tokens: normalized(grammar.tokens(in: source), for: source)
        )
    }

    func highlight(_ source: String, languageIdentifier: String) throws -> HighlightedCode {
        if let bundledLanguage = SyntaxLanguage.resolve(languageIdentifier),
           grammars[bundledLanguage] != nil {
            return try highlight(source, language: bundledLanguage)
        }

        let customLanguage = SyntaxLanguage(rawValue: languageIdentifier)

        guard grammars[customLanguage] != nil else {
            throw SyntaxHighlightingError.unsupportedLanguage(languageIdentifier)
        }

        return try highlight(source, language: customLanguage)
    }

    private func normalized(_ tokens: [SyntaxToken], for source: String) -> [SyntaxToken] {
        let sortedTokens = tokens
            .filter { token in
                token.range.isEmpty == false
                    && token.range.lowerBound >= source.startIndex
                    && token.range.upperBound <= source.endIndex
            }
            .sorted { first, second in
                if first.range.lowerBound == second.range.lowerBound {
                    return first.range.upperBound < second.range.upperBound
                }

                return first.range.lowerBound < second.range.lowerBound
            }

        var result = [SyntaxToken]()
        var previousUpperBound = source.startIndex

        for token in sortedTokens where token.range.lowerBound >= previousUpperBound {
            let scopes = token.scopes.isEmpty ? [token.kind.rawValue] : token.scopes
            result.append(SyntaxToken(kind: token.kind, range: token.range, scopes: scopes))
            previousUpperBound = token.range.upperBound
        }

        return result
    }
}
