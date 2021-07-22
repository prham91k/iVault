//
//  XMRFormatterTest.swift
//  XWalletTests
//
//  Created by loj on 17.12.17.
//

import XCTest
import iVault


class XMRFormatterTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    public func testXMRFormatter_fromFormatted() {
        // Arange
        let stringAmount = "22.08"
        let expectedResult: UInt64 = 22080000000000
        
        // Act
        let result = XMRFormatter.fromFormatted(amount: stringAmount)
        
        // Assert
        XCTAssertEqual(expectedResult, result)
    }
    
}
