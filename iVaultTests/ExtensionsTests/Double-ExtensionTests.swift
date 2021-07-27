//
//  Double-ExtensionTests.swift
//  XWalletTests
//
//  Created by loj on 24.06.18.
//

import XCTest

class Double_ExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    public func test_toXMR_Success() {
        let givenDouble: Double = 11.01
        let expectedUInt64: UInt64 = 11010000000000

        let result = givenDouble.toXMR()

        XCTAssertEqual(expectedUInt64, result)
    }

    public func test_toXMR_Error() {
        let givenDouble: Double = 99999999

        let result = givenDouble.toXMR()

        XCTAssertEqual(nil, result)
    }

}
