//
//  FiatProviderTest.swift
//  XWalletTests
//
//  Created by loj on 18.03.18.
//

import XCTest
import iVault


class FiatProviderIntegrationTest: XCTestCase {
    
    private var testee: FiatProvider!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.testee = FiatProvider()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    public func test_getFiatValue_retrievesValueFromWebService() {
        let expectation = self.expectation(description: "fiat value handler")
        let currency = "CHF"
        
        self.testee.getFiatEquivalent(
            forCurrency: currency,
            completionHandler: {
                (fiatValue: Double, currency: String) in
                print("##### fiatValue: \(fiatValue)")
                expectation.fulfill()},
            failedHandler: {})
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
