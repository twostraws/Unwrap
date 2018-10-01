//
//  UnwrapUITests.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
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
    
    //Check that trying to share score displays the ActivityView on the HomeViewController
    func testShareScoreShows() {
        let app = XCUIApplication()
        
        app.tables.cells["Stat"].staticTexts["Share Score"].tap()
        
        //Delay ActivityViewController to verify the right buttons exist
        let predicate = NSPredicate(format: "exists == 1")
        let query = app.collectionViews.cells.collectionViews.containing(.button, identifier: "More").element
        
        expectation(for: predicate, evaluatedWith: query, handler: nil)
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    //Check that tapping Help on the HomeViewController and then Credit show the correct controllers
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
