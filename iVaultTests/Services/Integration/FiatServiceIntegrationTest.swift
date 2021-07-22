//
//  FiatServiceTest.swift
//  XWalletTests
//
//  Created by loj on 18.03.18.
//

import XCTest
import iVault


class FiatServiceIntegrationTest: XCTestCase {
    
    private var testee: FiatService!
    private var propertyStoreMock: PropertyStoreMock!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.propertyStoreMock = PropertyStoreMock()
        let fiatProvider = FiatProvider()
        let dateProvider = DateProvider()
        
        self.testee = FiatService(fiatProvider: fiatProvider,
                                  dateProvider: dateProvider,
                                  propertyStore: self.propertyStoreMock)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    public func test_periodicFiatUpdates() {
        let expectation = self.expectation(description: "fiat service")
        let numberOfExpectedResults = 3
        var currentNumberOfResults = 0
        
        self.propertyStoreMock.currency = "USD"
        let interval = 5
        
        self.testee.startUpdating(withIntervalInSeconds: interval) {
            currentNumberOfResults += 1
            if currentNumberOfResults >= numberOfExpectedResults {
                self.testee.stopUpdating()
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 30.0, handler: nil)
    }

    
    private class PropertyStoreMock: PropertyStoreProtocol {
        func wipeAll() {}
        
        var deprecatedAppPin: String?
        var onboardingIsFinished: Bool = true
        var language: String = ""
        var currency: String = ""
        var nodeAddress: String = ""
        var lastFiatUpdate: Date?
        var lastFiatFactor: Double?
        var feeInAtomicUnits: UInt64 = 0
    }}

