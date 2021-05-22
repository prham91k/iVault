//
//  UInt64-Extension.swift
//  XWallet
//
//  Created by loj on 11.08.17.
//

import Foundation


extension UInt64 {
    
    public func toUInt8() -> [UInt8] {
        var me = self
        return withUnsafeBytes(of: &me) { Array($0).reversed() }
    }

    public func toXMR() -> Double {
        return Double(self) / Double(Constants.atomicUnitsPerMonero)
    }
}
