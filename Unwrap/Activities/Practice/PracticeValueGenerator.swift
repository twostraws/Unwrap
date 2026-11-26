//
//  PracticeValueGenerator.swift
//  Unwrap
//

import Foundation

struct PracticeValueGenerator {
    struct StringChoice: Equatable {
        let name: String
        let naturalName: String
        let values: [String]
    }

    enum ValueType: String, CaseIterable {
        case string = "String"
        case integer = "Int"
        case boolean = "Bool"
        case double = "Double"
        case float = "Float"
    }

    private let random: any RandomProviding

    init(random: any RandomProviding) {
        self.random = random
    }

    func letOrVar() -> String {
        random.nextInt(in: 0...1) == 0 ? "let" : "var"
    }

    func boolean() -> String {
        random.nextInt(in: 0...1) == 0 ? "false" : "true"
    }

    func integerName() -> (name: String, naturalName: String) {
        let naturalName = random.element(from: Self.integerNames) ?? "value"
        return (Self.variableName(from: naturalName), naturalName)
    }

    func booleanName() -> String {
        random.element(from: Self.booleanNames) ?? "isEnabled"
    }

    func stringChoice() -> StringChoice {
        let choice = random.element(from: Self.stringChoices) ?? Self.fallbackStringChoice
        var values = random.shuffled(choice.values)

        if choice.naturalName == "address" {
            let streetTypes = ["Road", "Street", "Avenue", "Court", "Lane", "Place", "Drive", "Terrace"]
            values = values.prefix(10).map { streetName in
                let number = random.nextInt(in: 1...100)
                let streetType = random.element(from: streetTypes) ?? "Road"
                return "\(number) \(streetName) \(streetType)"
            }
        }

        return StringChoice(
            name: Self.variableName(from: choice.naturalName),
            naturalName: choice.naturalName,
            values: Array(values.prefix(10))
        )
    }

    func comparisonOperator() -> String {
        random.element(from: ["<", ">", "<=", ">=", "==", "!="]) ?? "=="
    }

    func instance(of type: ValueType) -> String {
        let storage = letOrVar()

        switch type {
        case .string:
            let choice = stringChoice()
            let annotation = includesTypeAnnotation() ? ": String" : ""
            let value = random.element(from: choice.values) ?? "Swift"
            return "\(storage) \(choice.name)\(annotation) = \"\(value)\""

        case .integer:
            let name = integerName().name
            let annotation = includesTypeAnnotation() ? ": Int" : ""
            return "\(storage) \(name)\(annotation) = \(random.nextInt(in: 1...9))"

        case .boolean:
            let annotation = includesTypeAnnotation() ? ": Bool" : ""
            return "\(storage) \(booleanName())\(annotation) = \(boolean())"

        case .double:
            let annotation = includesTypeAnnotation() ? ": Double" : ""
            var value = floatingPointValue()
            if annotation.isEmpty, value.contains(".") == false {
                value.append(".0")
            }
            return "\(storage) \(floatingPointName())\(annotation) = \(value)"

        case .float:
            return "\(storage) \(floatingPointName()): Float = \(floatingPointValue())"
        }
    }

    private func includesTypeAnnotation() -> Bool {
        random.nextInt(in: 0...1) == 1
    }

    private func floatingPointName() -> String {
        random.element(from: Self.floatingPointNames) ?? "value"
    }

    private func floatingPointValue() -> String {
        let scale = random.element(from: [1.0, 10.0, 100.0]) ?? 1.0
        let fraction = Double(random.nextInt(in: 0...10_000)) / 10_000
        return (fraction * scale).formatted(
            .number
                .locale(Locale(identifier: "en_US_POSIX"))
                .precision(.significantDigits(1...4))
        )
    }

    private static func variableName(from naturalName: String) -> String {
        let parts = naturalName.split(separator: " ")
        guard let first = parts.first else { return "value" }

        return parts.dropFirst().reduce(first.lowercased()) { result, part in
            result + part.capitalized
        }
    }

    private static let integerNames = [
        "age", "birds", "books", "bottles", "cars", "customers", "days", "employees", "goals",
        "high score", "hours", "minutes", "months", "number of users", "people", "points", "sales",
        "score", "seconds", "sides", "teams", "users", "weeks"
    ]

    private static let booleanNames = [
        "isAnimated", "isAuthenticated", "isActive", "isDeleted", "isEdited", "isEditing", "isEnabled",
        "isEncrypted", "isFirstResponder", "isFocused", "isHidden", "isLandscape", "isLoaded", "isLoggedIn",
        "isModal", "isOpaque", "isPortrait", "isPresented", "isRecognized", "isRead", "isReady", "isSaved",
        "isSelected", "isSorted", "isStatic", "isUnlocked", "isVisible", "isZoomed"
    ]

    private static let floatingPointNames = [
        "days", "depth", "distance", "height", "hours", "minutes", "months", "multiplier", "score", "seconds",
        "temperature", "weeks", "weight", "width"
    ]

    private static let stringChoices = [
        StringChoice(
            name: "address",
            naturalName: "address",
            values: [
                "Station", "Friar's", "Chapel", "King Edward", "Field", "Weston", "Clarence", "Park",
                "Carlton", "Illinois", "Alabama", "Indiana", "Albion", "Pearl", "Hermosa", "Market",
                "Bell Fork", "Fletcher", "Cole", "Armstrong", "Carver", "Pebble Lane", "Pine Valley",
                "Scottsdale", "Augusta", "Bingham", "Seymour", "Ryan"
            ]
        ),
        StringChoice(
            name: "city",
            naturalName: "city",
            values: [
                "Adelaide", "Albany", "Atlanta", "Auckland", "Austin", "Belfast", "Birmingham", "Boston",
                "Brisbane", "Bristol", "Cambridge", "Cardiff", "Chicago", "Columbus", "Coventry", "Dover",
                "Edinburgh", "Glasgow", "Houston", "Indianapolis", "Leeds", "Liverpool", "London", "Manchester",
                "Melbourne", "Nashville", "Newcastle", "New York", "Nottingham", "Oxford", "Perth", "Phoenix",
                "Portland", "Portsmouth", "Queenstown", "Sheffield", "Southampton", "Sydney", "York"
            ]
        ),
        StringChoice(
            name: "favoriteColor",
            naturalName: "favorite color",
            values: [
                "beige", "black", "blue", "brown", "cyan", "crimson", "fuchsia", "gold", "green", "indigo",
                "lilac", "magenta", "orange", "pink", "purple", "red", "scarlet", "teal", "turquoise",
                "violet", "white", "yellow"
            ]
        ),
        StringChoice(
            name: "favoriteFood",
            naturalName: "favorite food",
            values: [
                "burger", "Caesar salad", "cheeseburger", "chicken wings", "fish and chips", "fried chicken",
                "hotdog", "ice cream", "jacket potato", "lasagna", "nachos", "omelette", "onion rings", "pasta",
                "pizza", "rack of ribs", "sandwich", "spaghetti", "steak"
            ]
        ),
        StringChoice(
            name: "name",
            naturalName: "name",
            values: [
                "Ada", "Adele", "Alvin", "Andrew", "Anthony", "Charlotte", "Damir", "Daniel", "Dawn",
                "Eleanor", "Emran", "Grace", "Jane", "Jing", "John", "Jun", "Justin", "Kamal", "Ming",
                "Molly", "Naomi", "Omar", "Paul", "Peter", "Rhea", "Sonya", "Sophie", "Tamir", "Taylor", "Wei"
            ]
        )
    ]

    private static let fallbackStringChoice = StringChoice(
        name: "name",
        naturalName: "name",
        values: ["Taylor"]
    )
}
