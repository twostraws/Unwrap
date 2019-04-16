//
//  UnwrapUITests.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import XCTest

class UnwrapUITests: XCTestCase {
    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /// Check that all fundamental components on the home screen exist
    func testHomeViewControllerExists() {
        let app = XCUIApplication()
        let tabBarsQuery = XCUIApplication().tabBars

        tabBarsQuery.buttons["Home"].tap()

        XCTAssertTrue(app.tables.otherElements["Ring progress"].exists)
        XCTAssertTrue(app.tables.cells["Rank"].exists)
        XCTAssertTrue(app.tables.cells["Points"].exists)
        XCTAssertTrue(app.tables.cells["Stat"].exists)
        XCTAssertTrue(app.tables.cells["Streak Reminder"].exists)
        XCTAssertTrue(app.tables.cells["Badges"].exists)
    }

    /// Check that tapping Help on the HomeViewController and then Credit show the correct controllers
    func testHelpAndCreditShow() {
        let app = XCUIApplication()
        let tabBarsQuery = XCUIApplication().tabBars

        tabBarsQuery.buttons["Home"].tap()

        XCTAssertTrue(app.buttons["Help"].exists)

        app.buttons["Help"].tap()

        XCTAssertTrue(app.navigationBars["Help"].exists)
        XCTAssertTrue(app.buttons["Credits"].exists)

        app.buttons["Credits"].tap()

        XCTAssert(app.navigationBars["Credits"].exists)
    }
}
