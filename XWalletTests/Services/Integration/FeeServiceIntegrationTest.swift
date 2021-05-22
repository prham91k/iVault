//
//  FeeServiceIntegrationTest.swift
//  XWalletTests
//
//  Created by loj on 01.05.18.
//

import XCTest
import XWallet


class FeeServiceIntegrationTest: XCTestCase {
    
    private var testee: FeeService!
    private var propertyStoreMock: PropertyStoreMock!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.propertyStoreMock = PropertyStoreMock()
        let feeProvider = FeeProvider()
        self.testee = FeeService(feeProvider: feeProvider, propertyStore: self.propertyStoreMock)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    public func test_periodicFeeUpdates() {
        let expectation = self.expectation(description: "fee service")
        let messageSizeInKB = 13
        let numberOfExpectedResults = 3
        var currentNumberOfResults = 0
        
        let interval = 5
        
        self.testee.startUpdating(withIntervalInSeconds: interval) {
            currentNumberOfResults += 1
            let fee = self.testee.getFeeInAtomicUnits(forMessageSizeInKB: messageSizeInKB)
            print("#### query no. \(currentNumberOfResults), fee: \(fee)")
            if currentNumberOfResults >= numberOfExpectedResults {
                self.testee.stopUpdating()
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 30.0, handler: nil)
    }


    private class PropertyStoreMock: PropertyStoreProtocol {
        func wipeAll() {}
        
        var onboardingIsFinished: Bool = true
        var language: String = ""
        var currency: String = ""
        var nodeAddress: String = ""
        var lastFiatUpdate: Date?
        var lastFiatFactor: Double?
        var feeInAtomicUnits: UInt64 = 0
    }
}
