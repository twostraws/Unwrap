//
//  GenericNativeScanner+Configuration.swift
//  Unwrap
//

extension GenericNativeScanner {
    nonisolated struct Configuration: Sendable {
        let language: SyntaxLanguage
        let keywords: Set<String>
        let builtins: Set<String>
        let functions: Set<String>
        let booleans: Set<String>
        let classNames: Set<String>
        let builtinVariables: Set<String>
        let typeDeclarationKeywords: Set<String>
        let functionDeclarationKeywords: Set<String>
        let lineCommentMarkers: [String]
        let blockComments: [BlockComment]
        let stringDelimiters: [StringDelimiter]
        let operators: [String]
        let variablePrefixes: [String]
        let additionalIdentifierStartCharacters: Set<Character>
        let additionalIdentifierBodyCharacters: Set<Character>
        let isCaseInsensitive: Bool
        let classifiesCapitalizedIdentifiersAsClasses: Bool
        let classifiesCallsBeforeBracesAsFunctions: Bool
        let recognizesHashDirectives: Bool
        let recognizesCppRawStrings: Bool
        let recognizesMarkupTags: Bool
        let recognizesSlashRegexLiterals: Bool
        let regexPrefixKeywords: Set<String>
        let recognizesCSSSelectors: Bool
        let stringKeysAreProperties: Bool
        let identifiersBeforeColon: SyntaxTokenKind?
        let colonClassificationRequiresBraces: Bool

        init(
            language: SyntaxLanguage,
            keywords: Set<String> = [],
            builtins: Set<String> = [],
            functions: Set<String> = [],
            booleans: Set<String> = ["true", "false"],
            classNames: Set<String> = [],
            builtinVariables: Set<String> = [],
            typeDeclarationKeywords: Set<String> = [
                "class", "enum", "interface", "object", "record", "struct", "trait", "type"
            ],
            functionDeclarationKeywords: Set<String> = ["def", "fn", "func", "function"],
            lineCommentMarkers: [String] = [],
            blockComments: [BlockComment] = [],
            stringDelimiters: [StringDelimiter] = [],
            operators: [String] = [],
            variablePrefixes: [String] = [],
            additionalIdentifierStartCharacters: Set<Character> = [],
            additionalIdentifierBodyCharacters: Set<Character> = [],
            isCaseInsensitive: Bool = false,
            classifiesCapitalizedIdentifiersAsClasses: Bool = false,
            classifiesCallsBeforeBracesAsFunctions: Bool = false,
            recognizesHashDirectives: Bool = false,
            recognizesCppRawStrings: Bool = false,
            recognizesMarkupTags: Bool = false,
            recognizesSlashRegexLiterals: Bool = false,
            regexPrefixKeywords: Set<String> = [],
            recognizesCSSSelectors: Bool = false,
            stringKeysAreProperties: Bool = false,
            identifiersBeforeColon: SyntaxTokenKind? = nil,
            colonClassificationRequiresBraces: Bool = false
        ) {
            self.language = language
            self.isCaseInsensitive = isCaseInsensitive
            self.keywords = Self.normalized(keywords, caseInsensitive: isCaseInsensitive)
            self.builtins = Self.normalized(builtins, caseInsensitive: isCaseInsensitive)
            self.functions = Self.normalized(functions, caseInsensitive: isCaseInsensitive)
            self.booleans = Self.normalized(booleans, caseInsensitive: isCaseInsensitive)
            self.classNames = Self.normalized(classNames, caseInsensitive: isCaseInsensitive)
            self.builtinVariables = Self.normalized(builtinVariables, caseInsensitive: isCaseInsensitive)
            self.typeDeclarationKeywords = Self.normalized(
                typeDeclarationKeywords,
                caseInsensitive: isCaseInsensitive
            )
            self.functionDeclarationKeywords = Self.normalized(
                functionDeclarationKeywords,
                caseInsensitive: isCaseInsensitive
            )
            self.lineCommentMarkers = lineCommentMarkers.sorted { $0.count > $1.count }
            self.blockComments = blockComments.sorted { $0.opening.count > $1.opening.count }
            self.stringDelimiters = stringDelimiters.sorted { $0.opening.count > $1.opening.count }
            self.operators = operators.sorted { $0.count > $1.count }
            self.variablePrefixes = variablePrefixes.sorted { $0.count > $1.count }
            self.additionalIdentifierStartCharacters = additionalIdentifierStartCharacters
            self.additionalIdentifierBodyCharacters = additionalIdentifierBodyCharacters
            self.classifiesCapitalizedIdentifiersAsClasses = classifiesCapitalizedIdentifiersAsClasses
            self.classifiesCallsBeforeBracesAsFunctions = classifiesCallsBeforeBracesAsFunctions
            self.recognizesHashDirectives = recognizesHashDirectives
            self.recognizesCppRawStrings = recognizesCppRawStrings
            self.recognizesMarkupTags = recognizesMarkupTags
            self.recognizesSlashRegexLiterals = recognizesSlashRegexLiterals
            self.regexPrefixKeywords = Self.normalized(
                regexPrefixKeywords,
                caseInsensitive: isCaseInsensitive
            )
            self.recognizesCSSSelectors = recognizesCSSSelectors
            self.stringKeysAreProperties = stringKeysAreProperties
            self.identifiersBeforeColon = identifiersBeforeColon
            self.colonClassificationRequiresBraces = colonClassificationRequiresBraces
        }

        private static func normalized(
            _ values: Set<String>,
            caseInsensitive: Bool
        ) -> Set<String> {
            guard caseInsensitive else { return values }
            return Set(values.map { $0.lowercased() })
        }
    }
}
