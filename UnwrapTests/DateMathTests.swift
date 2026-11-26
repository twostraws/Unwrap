//
//  DateMathTests.swift
//  UnwrapTests
//

import Foundation
import Testing
@testable import Unwrap

/// Streaks and daily challenges both depend on calendar days, so these pin the awkward edges
/// using fixed calendars rather than whatever the test device happens to be set to.
@Suite("Calendar day arithmetic")
struct DateMathTests {
    @Test("Two minutes either side of midnight are different days")
    func midnightSeparatesDays() throws {
        let calendar = try calendar(in: "Europe/London")
        let lateEvening = try date(2026, 1, 15, hour: 23, minute: 59, in: calendar)
        let nextMorning = try date(2026, 1, 16, hour: 0, minute: 1, in: calendar)

        #expect(lateEvening.isSameDay(as: nextMorning, calendar: calendar) == false)
        #expect(lateEvening.days(between: nextMorning, calendar: calendar) == 1)
    }

    @Test("The first and last minutes of one day are the same day")
    func wholeDayIsOneDay() throws {
        let calendar = try calendar(in: "Europe/London")
        let earlyMorning = try date(2026, 1, 15, hour: 0, minute: 1, in: calendar)
        let lateEvening = try date(2026, 1, 15, hour: 23, minute: 59, in: calendar)

        #expect(earlyMorning.isSameDay(as: lateEvening, calendar: calendar))
        #expect(earlyMorning.days(between: lateEvening, calendar: calendar) == 0)
        #expect(earlyMorning.days(between: earlyMorning, calendar: calendar) == 0)
    }

    @Test("The same two instants can share a day in one time zone and not in another")
    func daysDependOnTimeZone() throws {
        let london = try calendar(in: "Europe/London")
        let losAngeles = try calendar(in: "America/Los_Angeles")
        let beforeLondonMidnight = try date(2026, 1, 15, hour: 23, minute: 30, in: london)
        let afterLondonMidnight = try date(2026, 1, 16, hour: 0, minute: 30, in: london)

        #expect(beforeLondonMidnight.isSameDay(as: afterLondonMidnight, calendar: london) == false)
        #expect(beforeLondonMidnight.isSameDay(as: afterLondonMidnight, calendar: losAngeles))
        #expect(beforeLondonMidnight.days(between: afterLondonMidnight, calendar: london) == 1)
        #expect(beforeLondonMidnight.days(between: afterLondonMidnight, calendar: losAngeles) == 0)
    }

    @Test("Day differences are the same in either direction")
    func differencesAreSymmetric() throws {
        let calendar = try calendar(in: "Europe/London")
        let earlier = try date(2026, 2, 27, hour: 18, in: calendar)
        let later = try date(2026, 3, 2, hour: 6, in: calendar)

        #expect(earlier.days(between: later, calendar: calendar) == 3)
        #expect(later.days(between: earlier, calendar: calendar) == 3)
    }

    @Test("The 23-hour day when clocks go forward still counts as exactly one day")
    func springForward() throws {
        // Daylight saving time started in New York on March 8, 2026.
        let calendar = try calendar(in: "America/New_York")
        let dayBefore = try date(2026, 3, 7, hour: 12, in: calendar)
        let startOfShortDay = try date(2026, 3, 8, hour: 0, minute: 30, in: calendar)
        let endOfShortDay = try date(2026, 3, 8, hour: 23, minute: 30, in: calendar)
        let dayAfter = try date(2026, 3, 9, hour: 12, in: calendar)

        #expect(startOfShortDay.isSameDay(as: endOfShortDay, calendar: calendar))
        #expect(dayBefore.days(between: endOfShortDay, calendar: calendar) == 1)
        #expect(startOfShortDay.days(between: dayAfter, calendar: calendar) == 1)
        #expect(dayBefore.days(between: dayAfter, calendar: calendar) == 2)
    }

    @Test("The 25-hour day when clocks go back still counts as exactly one day")
    func fallBack() throws {
        // Daylight saving time ended in New York on November 1, 2026.
        let calendar = try calendar(in: "America/New_York")
        let startOfLongDay = try date(2026, 11, 1, hour: 0, minute: 30, in: calendar)
        let endOfLongDay = try date(2026, 11, 1, hour: 23, minute: 30, in: calendar)
        let nextDay = try date(2026, 11, 2, hour: 0, minute: 30, in: calendar)

        #expect(endOfLongDay.timeIntervalSince(startOfLongDay) == 24 * 60 * 60)
        #expect(startOfLongDay.isSameDay(as: endOfLongDay, calendar: calendar))
        #expect(startOfLongDay.days(between: endOfLongDay, calendar: calendar) == 0)
        #expect(startOfLongDay.days(between: nextDay, calendar: calendar) == 1)
    }

    @Test("Differences span month and leap-year boundaries")
    func longerSpans() throws {
        let calendar = try calendar(in: "Europe/London")
        let endOfFebruary = try date(2028, 2, 28, hour: 12, in: calendar)
        let startOfMarch = try date(2028, 3, 1, hour: 12, in: calendar)
        let newYearsEve = try date(2026, 12, 31, hour: 23, in: calendar)
        let newYearsDay = try date(2027, 1, 1, hour: 1, in: calendar)

        // 2028 is a leap year, so February 29 sits between these two dates.
        #expect(endOfFebruary.days(between: startOfMarch, calendar: calendar) == 2)
        #expect(newYearsEve.days(between: newYearsDay, calendar: calendar) == 1)
    }

    private func calendar(in timeZoneIdentifier: String) throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: timeZoneIdentifier))
        return calendar
    }

    private func date(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int,
        minute: Int = 0,
        in calendar: Calendar
    ) throws -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return try #require(calendar.date(from: components))
    }
}
