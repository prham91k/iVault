//
//  FiatAgeTest.swift
//  XWalletTests
//
//  Created by loj on 16.03.18.
//

import XCTest
import XWallet


class FiatAgeTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.seconds = 1.0
        self.minutes = 60.0 * seconds
        self.hours = 60.0 * minutes
        self.days = 24.0 * hours
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    private var seconds: Double!
    private var minutes: Double!
    private var hours: Double!
    private var days: Double!

    public func test_Recent() {
        let now = Date()
        let fiveMinutes: TimeInterval = 5.0 * minutes
        let recentAgo = Date(timeInterval: -fiveMinutes, since: now)
        
        let age = FiatAge.age(now: now, pastDate: recentAgo)
        
        XCTAssertEqual(age, FiatAge.recent)
    }

    public func test_MoreThan10Minutes() {
        let now = Date()
        let twentyMinutes: TimeInterval = 20.0 * minutes
        let recentAgo = Date(timeInterval: -twentyMinutes, since: now)
        
        let age = FiatAge.age(now: now, pastDate: recentAgo)
        
        XCTAssertEqual(age, FiatAge.moreThan10Minutes)
    }

    public func test_MoreThan1Hour() {
        let now = Date()
        let twoHours: TimeInterval = 2.0 * hours
        let recentAgo = Date(timeInterval: -twoHours, since: now)
        
        let age = FiatAge.age(now: now, pastDate: recentAgo)
        
        XCTAssertEqual(age, FiatAge.moreThan1Hour)
    }

    public func test_MoreThan1Day() {
        let now = Date()
        let twoDays: TimeInterval = 2.0 * days
        let recentAgo = Date(timeInterval: -twoDays, since: now)
        
        let age = FiatAge.age(now: now, pastDate: recentAgo)
        
        XCTAssertEqual(age, FiatAge.moreThan1Day)
    }
}
