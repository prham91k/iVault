//
//  FiatServiceTest.swift
//  XWalletTests
//
//  Created by loj on 11.03.18.
//

import XCTest
import XWallet

class FiatServiceTest: XCTestCase {
    
    private var testee: FiatService!
    private var fiatProviderMock: FiatProviderMock!
    private var dateProviderMock: DateProviderMock!
    private var propertyStoreMock: PropertyStoreMock!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.fiatProviderMock = FiatProviderMock()
        self.dateProviderMock = DateProviderMock()
        self.propertyStoreMock = PropertyStoreMock()
        self.testee = FiatService(fiatProvider: self.fiatProviderMock,
                                  dateProvider: self.dateProviderMock,
                                  propertyStore: self.propertyStoreMock)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.testee.stopUpdating()
    }
    

    func test_WhenNeverStarted_AndAskingForXMREquivalent_ThenReturnsNone() {
        let fiatValue = 22.08
        let expectedXMRValue = FiatEquivalent<UInt64>.none
        self.testee.stopUpdating()
        
        let xmrValue = self.testee.getXMR(forFiatValue: fiatValue)
        
        XCTAssertTrue(FiatServiceTest.areEqual(lhs: xmrValue, rhs: expectedXMRValue))
    }
    
    func test_WhenNeverStarted_AndAskingForFiatEquivalent_ThenReturnsNone() {
        let xmrValue: UInt64 = 2208
        let expectedFiatValue = FiatEquivalent<Double>.none
        self.testee.stopUpdating()
        
        let fiatValue = self.testee.getFiat(forXMRValue: xmrValue)
        
        XCTAssertTrue(FiatServiceTest.areEqual(lhs: fiatValue, rhs: expectedFiatValue))
    }
    
    func test_WhenStopped_ThenReturnsLastKnown() {
        let fiatValue = 22080.0
        let expectedAge = FiatAge.recent
        let expectedXMRValue: UInt64 = 2208_000_000_000_000
        let lastUpdate = Date()
        let lastFactor = 10.0
        self.dateProviderMock.fakeNow = lastUpdate
        self.propertyStoreMock.lastFiatUpdate = lastUpdate
        self.propertyStoreMock.lastFiatFactor = lastFactor
        let expectedResult = FiatEquivalent<UInt64>.value(age: expectedAge, amount: expectedXMRValue)
        self.testee.stopUpdating()
        
        let currentResult = self.testee.getXMR(forFiatValue: fiatValue)
        
        XCTAssertTrue(FiatServiceTest.areEqual(lhs: currentResult, rhs: expectedResult))
    }
    
    func test_WhenStarted_AndDidNotifiy_ThenGetsRecentFiatValue() {
        let fiatValue = 22080.0
        let xmrValue: UInt64 = 2208_000_000_000_000
        let fiatFactor = 10.0
        self.fiatProviderMock.factor = fiatFactor
        let expectedFiatValue = FiatEquivalent.value(age: .recent, amount: fiatValue)
        
        self.testee.startUpdating(withIntervalInSeconds: 60,
                                  notificationHandler: {
                                    let receivedFiatValue = self.testee.getFiat(forXMRValue: xmrValue)
                                    XCTAssertTrue(FiatServiceTest.areEqual(lhs: receivedFiatValue, rhs: expectedFiatValue))
        })
    }

    func test_WhenStarted_AndDidNotifiy_ThenGetsRecentXMRValue() {
        let fiatValue = 22080.0
        let xmrValue: UInt64 = 2208_000_000_000_000
        let fiatFactor = 10.0
        self.fiatProviderMock.factor = fiatFactor
        let expectedXMRValue = FiatEquivalent.value(age: .recent, amount: xmrValue)
        
        self.testee.startUpdating(withIntervalInSeconds: 60,
                                  notificationHandler: {
                                    let receivedXMRValue = self.testee.getXMR(forFiatValue: fiatValue)
                                    XCTAssertTrue(FiatServiceTest.areEqual(lhs: receivedXMRValue, rhs: expectedXMRValue))
        })
    }

    
    private class FiatProviderMock: FiatProviderProtocol {
        public var factor: Double = 1.0
        
        func getFiatEquivalent(forCurrency currency: String,
                               completionHandler: @escaping (Double, String) -> Void,
                               failedHandler: @escaping () -> Void)
        {
            completionHandler(factor, currency)
        }
    }
    
    
    private class DateProviderMock: DateProviderProtocol {
        public var fakeNow = Date()
        
        func now() -> Date {
            return self.fakeNow
        }
    }
    
    
    private class PropertyStoreMock: PropertyStoreProtocol {
        func wipeAll() {}
        
        var deprecatedAppPin: String?
        var onboardingIsFinished: Bool = true
        var language: String = ""
        var currency: String = ""
        var nodeAddress: String = ""
        
        var lastFiatUpdate: Date? = nil
        var lastFiatFactor: Double? = nil
        
        var feeInAtomicUnits: UInt64 = 0
    }
}


extension FiatServiceTest {
    
    private static func areEqual<T>(lhs: FiatEquivalent<T>, rhs: FiatEquivalent<T>) -> Bool where T: Comparable {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.value(age1, amount1), .value(age2, amount2)):
            return age1 == age2 && amount1 == amount2
        default:
            return false
        }
    }
}









