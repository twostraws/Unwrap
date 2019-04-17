//
//  StringNames.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation
import GameplayKit

extension String: TypeGenerating {
    static func randomName() -> (name: String, nameNatural: String, values: [String]) {
        let names = [
            "address": ["Station", "Friar's", "Chapel", "King Edward", "Field", "Weston", "Clarence", "Park", "Carlton", "Illinois", "Alabama", "Indiana", "Albion", "Pearl", "Hermosa", "Market", "Bell Fork", "Fletcher", "Cole", "Armstrong", "Carver", "Pebble Lane", "Pine Valley", "Scottsdale", "Augusta", "Bingham", "Seymour", "Ryan"],
            "city": ["Adelaide", "Albany", "Atlanta", "Auckland", "Austin", "Belfast", "Birmingham", "Boston", "Brisbane", "Bristol", "Cambridge", "Cardiff", "Chicago", "Columbus", "Coventry", "Dover", "Edinburgh", "Glasgow", "Houston", "Indianapolis", "Leeds", "Liverpool", "London", "Manchester", "Melbourne", "Nashville", "Newcastle", "New York", "Nottingham", "Oxford", "Perth", "Phoenix", "Portland", "Portsmouth", "Queenstown", "Sheffield", "Southampton", "Sydney", "York"],
            "favorite color": ["beige", "black", "blue", "brown", "cyan", "crimson", "fuschia", "gold", "green", "indigo", "lilac", "magenta", "orange", "pink", "purple", "red", "scarlet", "teal", "turquoise", "violet", "white", "yellow"],
            "favorite food": ["burger", "Caesar salad", "cheeseburger", "chicken wings", "fish and chips", "fried chicken", "hotdog", "ice cream", "jacket potato", "lasagna", "nachos", "omelette", "onion rings", "pasta", "pizza", "rack of ribs", "sandwich", "spaghetti", "steak"],
            "name": ["Ada", "Adele", "Alvin", "Andrew", "Anthony", "Charlotte", "Damir", "Daniel", "Dawn", "Eleanor", "Emran", "Grace", "Jane", "Jing", "John", "Jun", "Justin", "Kamal", "Ming", "Molly", "Naomi", "Omar", "Paul", "Peter", "Rhea", "Sonya", "Sophie", "Tamir", "Taylor", "Wei"]
        ]

        let keysArray = Array(names.keys)
        let randomItem = keysArray[GKRandomSource.sharedRandom().nextInt(upperBound: names.count)]
        let randomValues = names[randomItem]!.shuffled()
        let streetTypes = ["Road", "Street", "Avenue", "Court", "Lane", "Place", "Drive", "Terrace"]

        var values = [String]()

        if randomItem == "address" {
            for addressCounter in 0 ..< 10 {
                let randomNumber = arc4random_uniform(100) + 1
                let randomStreetType = streetTypes[Int(arc4random_uniform(UInt32(streetTypes.count)))]
                let resolvedAddress = "\(randomNumber) \(randomValues[addressCounter]) \(randomStreetType)"
                values.append(resolvedAddress)
            }
        } else {
            values.append(contentsOf: randomValues[0..<10])
        }

        return (randomItem.formatAsVariable(), randomItem, values)
    }

    static func randomOperator() -> String {
        let operators = ["<", ">", "<=", ">=", "==", "!="]
        let chosen = operators[GKRandomSource.sharedRandom().nextInt(upperBound: operators.count)]
        return chosen
    }

    static func makeInstance() -> String {
        let storage = letOrVar()
        let choice = randomName()
        let name = choice.name
        let type: String

        if includeType() {
            type = ": String"
        } else {
            type = ""
        }

        let selectedValue = choice.values.shuffled()[0]
        let value = "\"\(selectedValue)\""

        return "\(storage) \(name)\(type) = \(value)"
    }
}
