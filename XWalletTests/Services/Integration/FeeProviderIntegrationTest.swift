//
//  FeeProviderIntegrationTest.swift
//  XWalletTests
//
//  Created by loj on 01.05.18.
//

import XCTest
import XWallet


class FeeProviderIntegrationTest: XCTestCase {
    
    private var testee: FeeProvider!
    
    override func setUp() {
        super.setUp()
        
        self.testee = FeeProvider()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    public func test_getFee_retrieveFromWebService() {
        let expectation = self.expectation(description: "fee value handler")
        
        self.testee.getEstimatedFee(
            completionHandler: { (feeInAtomicUnits: UInt64) in
                print("#### fee in atomic units: \(feeInAtomicUnits)")
                expectation.fulfill()
        },
            failedHandler: {
                print("#### fee in atomic units FAILED")
        })
        
        waitForExpectations(timeout: 20.0, handler: nil)
    }
}
