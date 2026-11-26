//
//  Unwrap.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

enum Unwrap {
    /// The URL where users can go to share this app.
    static var appURL: URL {
        guard let url = URL(string: "https://apps.apple.com/app/id1440611372") else {
            preconditionFailure("The Unwrap App Store URL must be valid.")
        }

        return url
    }

    /// The static chapters for the app. These can be loaded up front – they never change while the app is running.
    static let chapters: [Chapter] = {
        do {
            let data = try Bundle.main.data(named: "Chapters.json")
            return try JSONDecoder().decode([Chapter].self, from: data)
        } catch {
            preconditionFailure("Unable to load Chapters.json: \(error)")
        }
    }()
}
