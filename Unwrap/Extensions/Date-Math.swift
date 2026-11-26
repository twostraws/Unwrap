//
//  Date-Math.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

extension Date {
    /// Returns true if two dates belong to the same day. Useful for deciding whether the user has taken today's daily challenge or not.
    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }

    /// Calculates the number of days between two dates. Useful for figuring out whether the user's current streak is still active.
    func days(between otherDate: Date, calendar: Calendar = .current) -> Int {
        let startOfSelf = calendar.startOfDay(for: self)
        let startOfOther = calendar.startOfDay(for: otherDate)
        let components = calendar.dateComponents([.day], from: startOfSelf, to: startOfOther)

        return abs(components.day ?? 0)
    }
}
