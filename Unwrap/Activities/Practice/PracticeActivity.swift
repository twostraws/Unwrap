//
//  PracticeActivity.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Describes what each practice activity needs to provide so that we can list it on the practice screen and instantiate it.
protocol PracticeActivity {
    static var name: String { get }
    static var subtitle: String { get }
    static var lockedUntil: String { get }
    static var isLocked: Bool { get }
    static var icon: UIImage { get }

    static func instantiate() -> UIViewController & PracticingViewController
}

extension PracticeActivity {
    /// Every activity knows when it should be unlocked, so we can calculate what is locked based on the user's rating.
    static var isLocked: Bool {
        let scoreForActivity = User.current.ratingForSection(lockedUntil.bundleName)
        return scoreForActivity == 0
    }
}
