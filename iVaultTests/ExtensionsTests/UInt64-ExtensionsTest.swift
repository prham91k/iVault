//
//  UInt64-ExtensionsTest.swift
//  XWallet
//
//  Created by loj on 11.08.17.
//

import XCTest

class UInt64_ExtensionsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    public func testUInt64_toUInt8() {
        // Arange
        let uint64: UInt64 = 0xa1a2a3a4a5a6a7a8
        let expected: [UInt8] = [0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8]
        
        // Act
        let uint8Array = uint64.toUInt8()
        
        // Assert
        XCTAssertEqual(expected, uint8Array)
    }
    
    public func testUInt64_toXMR() {
        let xmrInAtomicUnits = UInt64(2208_000_000_000_000)
        let expectedXMR = Double(2208.0)
        
        let computedXMR = xmrInAtomicUnits.toXMR()
        
        XCTAssertEqual(expectedXMR, computedXMR)
    }
}
